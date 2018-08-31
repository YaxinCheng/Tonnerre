//
//  TNEScript.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TNEScript: DisplayProtocol {
  enum Script {
    case python(path: URL)
    case appleScript(path: URL)
    
    init?(fileURL: URL) {
      switch fileURL.pathExtension {
      case "py":   self = .python(path: fileURL)
      case "scpt": self = .appleScript(path: fileURL)
      default: return nil
      }
    }
    
    fileprivate func execute(mode: DynamicScriptMode) -> Process? {
      do {
        switch self {
        case .python(path: _): return try pythonExec(mode: mode)
        case .appleScript(path: _): return try ASExec(mode: mode)
        }
      } catch {
        #if DEBUG
        print(error)
        #endif
        return nil
      }
    }
  }
  
  let name: String
  let content: String
  let icon: NSImage
  let placeholder: String
  private let script: Script
  var runningScript: Process?
  
  init?(name: String, content: String, icon: NSImage, scriptPath: URL, placeholder: String? = nil) {
    guard let script = Script(fileURL: scriptPath) else { return nil }
    self.name = name
    self.content = content
    self.icon = icon
    self.placeholder = placeholder ?? name
    self.script = script
  }
  
  func execute(mode: DynamicScriptMode) -> [DisplayProtocol] {
    let process = script.execute(mode: mode)
    runningScript?.terminate()
    runningScript = process
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
        return result.compactMap { decode($0, withIcon: icon, extraInfo: script) }
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

// TNEScript.Script functions all stores here
extension TNEScript.Script {
  private func pythonExec(mode: DynamicScriptMode) throws -> Process {
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
  
  private func ASExec(mode: DynamicScriptMode) throws -> Process? {
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
