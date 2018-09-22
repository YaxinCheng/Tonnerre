//
//  TNEScript.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct TNEScript: DisplayProtocol {
  enum TNEArgument {
    case prepare(input: [String])
    case serve(choice: [String: Any])
    
    var argument: String {
      switch self {
      case .prepare(input: _): return "--prepare"
      case .serve(choice: _): return "--serve"
      }
    }
  }
  
  enum Script {
    case python(path: URL)
    case appleScript(path: URL)
    
    init?(fileURL: URL) {
      guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
      switch fileURL.pathExtension {
      case "py":   self = .python(path: fileURL)
      case "scpt": self = .appleScript(path: fileURL)
      default: return nil
      }
    }
    
    var path: URL {
      switch self {
      case .python(path: let path),
           .appleScript(path: let path): return path
      }
    }
    
    fileprivate func execute(args: TNEArgument) -> Process? {
      do {
        switch self {
        case .python(path: _): return try pythonExec(mode: args)
        case .appleScript(path: _): return try ASExec(mode: args)
        }
      } catch {
        #if DEBUG
        print(error)
        #endif
        return nil
      }
    }
  }
  
  private static var processManager: [String: Process] = [:]
  
  let name: String
  var content: String
  let icon: NSImage
  let placeholder: String
  let keyword: String
  private let script: Script
  var path: URL {
    return script.path
  }
  var id: String {
    return path.path
  }
  let lowerBound: Int
  let upperBound: Int
  private static let validExtensions = [".py", ".scpt"]
  
  init?(scriptPath: URL) {
    var validScript: Script! = nil
    for ext in TNEScript.validExtensions {
      let exePath = scriptPath.appendingPathComponent("main" + ext)
      if let script = Script(fileURL: exePath) {
        validScript = script
        break
      }
    }
    guard validScript != nil else { return nil }
    let iconURL = scriptPath.appendingPathComponent("icon.png")
    let fileIcon = NSImage(contentsOf: iconURL)
    let jsonURL = scriptPath.appendingPathComponent("description.json")
    do {
      let jsonData = try Data(contentsOf: jsonURL)
      let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? Dictionary<String, Any>
      guard
        let descriptionObj = jsonObject,
        let name = descriptionObj["name"] as? String,
        let keyword = descriptionObj["keyword"] as? String
        else { return nil }
      let icon: NSImage
      if fileIcon != nil { icon = fileIcon! }
      else if let iconPath = descriptionObj["icon"] as? String, let iconFromPath = NSImage(contentsOfFile: iconPath) {
        icon = iconFromPath
      } else { icon = #imageLiteral(resourceName: "tonnerre_extension").tintedImage(with: TonnerreTheme.current.imgColour) }
      let placeholder = descriptionObj["placeholder"] as? String
      let lowerBound = descriptionObj["lowerBound"] as? Int ?? 1
      let upperBound = descriptionObj["upperBound"] as? Int ?? .max
      self.init(keyword: keyword, name: name, content: descriptionObj["content"] as? String ?? "", icon: icon, script: validScript, placeholder: placeholder, lowerBound: lowerBound, upperBound: upperBound)
    } catch {
      #if DEBUG
      print("Error happened in script constructor: ", error)
      #endif
      return nil
    }
  }
  
  init(keyword: String, name: String, content: String, icon: NSImage, script: Script, placeholder: String? = nil, lowerBound: Int, upperBound: Int) {
    self.script = script
    self.keyword = keyword
    self.name = name
    self.content = content
    self.icon = icon
    self.placeholder = placeholder ?? keyword
    self.lowerBound = lowerBound
    self.upperBound = upperBound
  }
  
  func execute(args: TNEArgument) -> [DisplayProtocol] {
    let process = script.execute(args: args)
    type(of: self).processManager[id]?.terminate()
    type(of: self).processManager[id] = process
    do {
      switch script {
      case .python(path: _):
        try process?.run()
      case .appleScript(path: _):
        if let asProc = process { try asProc.run() }
        else { return [DisplayableContainer<Any>(name: name, content: content, icon: icon)] }
      }
      let runningError = (process?.standardError as? Pipe)?.fileHandleForReading.readDataToEndOfFile()
      if let errorData = runningError,
        !errorData.isEmpty,
        let errorDict = try JSONSerialization.jsonObject(with: errorData, options: .mutableLeaves) as? Dictionary<String, Any>,
        let error = errorDict["error"],
        let errorItem = decode(["name": "Error", "content": error, "placeholder": ""], withIcon: icon)
      {
        return [errorItem]
      }
      let runningResult = (process?.standardOutput as? Pipe)?.fileHandleForReading.readDataToEndOfFile()
      if let resultData = runningResult,
        !resultData.isEmpty,
        let result = try JSONSerialization.jsonObject(with: resultData, options: .mutableLeaves) as? [Dictionary<String, Any>] {
        return result.compactMap { decode($0, withIcon: icon, extraInfo: self) }
      }
    } catch {
      #if DEBUG
      print("script execute error", error)
      #endif
    }
    return []
  }
  
  private func decode(_ jsonObject: Dictionary<String, Any>, withIcon: NSImage, extraInfo: Any? = nil) -> DisplayProtocol? {
    guard
      let rawName = jsonObject["name"]
      else { return nil }
    let name: String = rawName as? String ?? String(reflecting: rawName)
    let content = jsonObject["content"] as? String ?? ""
    let innerItem = jsonObject["innerItem"]
    let placeholder = jsonObject["placeholder"] as? String ?? name
    if
      let stringItem = innerItem as? String,
      let urlItem = URL(string: stringItem),
      let _ = NSWorkspace.shared.urlForApplication(toOpen: urlItem) {
      return DisplayableContainer(name: name, content: content, icon: withIcon, innerItem: urlItem, placeholder: placeholder, extraContent: extraInfo)
    } else {
      return DisplayableContainer<Any>(name: name, content: content, icon: withIcon, innerItem: innerItem, placeholder: placeholder, extraContent: extraInfo)
    }
  }
}

// Mark: - TNEScript.Script functions all stores here
extension TNEScript.Script: Equatable {
  static func == (lhs: TNEScript.Script, rhs: TNEScript.Script) -> Bool {
    return lhs.path == rhs.path
  }
  
  private func pythonExec(mode: TNEScript.TNEArgument) throws -> Process {
    guard
      case .python(let scriptPath) = self,
      FileManager.default.fileExists(atPath: scriptPath.path)
    else { throw TNEScriptError.fileNotFound }
    let (inputPipe, outputPipe, errorPipe) = (Pipe(), Pipe(), Pipe())
    let process = Process()
    process.arguments = [Bundle.main.url(forResource: "DynamicServiceExec", withExtension: "py")!.path, mode.argument, scriptPath.path]
    let userDefault = UserDefaults.shared
    let pythonPath = (userDefault[.python] as? String) ?? "/usr/bin/python"
    process.executableURL = URL(fileURLWithPath: pythonPath)
    process.standardInput = inputPipe
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    switch mode {
    case .prepare(input: let input) where !input.isEmpty:
      inputPipe.fileHandleForWriting.write(try JSONSerialization.data(withJSONObject: input, options: .prettyPrinted))
    case .serve(choice: let choice) where !choice.isEmpty:
      inputPipe.fileHandleForWriting.write(try JSONSerialization.data(withJSONObject: choice, options: .prettyPrinted))
    default: break
    }
    inputPipe.fileHandleForWriting.closeFile()
    return process
  }
  
  private func ASExec(mode: TNEScript.TNEArgument) throws -> Process? {
    guard
      case .appleScript(let scriptPath) = self,
      FileManager.default.fileExists(atPath: scriptPath.path)
    else { throw TNEScriptError.fileNotFound }
    switch mode {
    case .prepare(input: _): return nil
    case .serve(choice: _):
      let process = Process()
      process.arguments = [scriptPath.path]
      process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
      return process
    }
  }
}

extension TNEScript: Equatable {
  static func == (lhs: TNEScript, rhs: TNEScript) -> Bool {
    return lhs.script == rhs.script
  }
}
