//
//  DynamicService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class DynamicService: TonnerreService, DynamicProtocol {
  static let keyword: String = ""
  var icon: NSImage {
    return #imageLiteral(resourceName: "extension").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  
  var serviceTrie: Trie<ServiceType>
  
  private let encode = JSONSerialization.data
  private let asyncSession = TonnerreSession.shared
  private typealias ExtraContent = (keyword: String, runtime: String?)
  
  // MARK: - Tool
  private func decode(_ jsonObject: Dictionary<String, Any>, withIcon: NSImage, extraInfo: Any? = nil) -> DisplayProtocol? {
    guard
      let rawName = jsonObject["name"]
    else { return nil }
    let name: String = String(reflecting: rawName)
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
  
  private func dictionarize(_ displayItem: DisplayProtocol) -> Dictionary<String, Any> {
    let unwrap: (Any) -> Any = {
      let mirror = Mirror(reflecting: $0)
      guard
        mirror.displayStyle == .optional,
        let value = mirror.children.first
      else { return $0 }
      return value.value
    }
    let requiredKeys: Set<String> = ["name", "content", "innerItem"]
    return Dictionary(uniqueKeysWithValues:
      Mirror(reflecting: displayItem).children
      .filter { requiredKeys.contains(($0.label ?? "")) }
      .map { ($0.label!, String(reflecting: unwrap($0.value))) }
    )
  }
  
  // MARK: - Constructions
  
  /**
   Parse information in a json file to get the service
   - parameter url: the url to the TNE script
   - returns: (keyword, DisplayableContainer with information in the JSON)
  */
  static func generateService(from url: URL) -> [ServiceType] {
    let script = url.appendingPathComponent("main.py")
    guard FileManager.default.fileExists(atPath: script.path) else { return [] }
    let iconURL = url.appendingPathComponent("icon.png")
    let fileIcon = NSImage(contentsOf: iconURL)
    let jsonURL = url.appendingPathComponent("description.json")
    do {
      let jsonData = try Data(contentsOf: jsonURL)
      let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? Dictionary<String, String>
      guard
        let descriptionObj = jsonObject,
        let name = descriptionObj["name"],
        let keyword = descriptionObj["keyword"]
      else { return [] }
      let pythonRuntime: String? = descriptionObj["runtime"] ?? nil
      let icon: NSImage
      if fileIcon != nil { icon = fileIcon! }
      else if let iconPath = descriptionObj["icon"], let iconFromPath = NSImage(contentsOfFile: iconPath) {
        icon = iconFromPath
      } else { icon = #imageLiteral(resourceName: "extension").tintedImage(with: TonnerreTheme.current.imgColour) }
      let item = DisplayableContainer(name: name, content: descriptionObj["content"] ?? "", icon: icon, innerItem: script.path, placeholder: descriptionObj["placeholder"] ?? "", extraContent: (keyword, pythonRuntime))
      return [item]
    } catch {
      #if DEBUG
      print("Error happened in generate service: ", error)
      #endif
      return []
    }
  }
  
  required init() {
    serviceTrie = Trie(values: []) { ($0.extraContent as! ExtraContent).keyword }
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      self.prefetch(fileExtension: "tne")
    }
  }
  
  func reload() {
    serviceTrie = Trie(values: []) { ($0.extraContent as! ExtraContent).keyword }
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      self.prefetch(fileExtension: "tne")
    }
  }
  
  // MARK: - Script Execute
  private enum Mode {
    case prepare(input: [String])
    case serve(choice: [String: Any])
    
    var argument: String {
      switch self {
      case .prepare(input: _): return "--prepare"
      case .serve(choice: _): return "--serve"
      }
    }
  }
  
  private static weak var runningProcess: Process?
  
  /**
   Run the given script for a specific mode
   - parameter script: a service that describes the python script file
   - parameter runningMode: either `prepare` or `serve`. It determines which function in the script should be called
   - throws: Error of process running; Error of JSONSerialization
   - returns: an array of running result, can be empty (if with serve mode)
  */
  private func execute(script: ServiceType, runningMode: Mode) throws -> [DisplayProtocol] {
    guard let scriptPath = script.innerItem, FileManager.default.fileExists(atPath: scriptPath) else { return [] }
    let process = Process()
    process.arguments = [Bundle.main.url(forResource: "DynamicServiceExec", withExtension: "py")!.path, runningMode.argument, scriptPath]
    let pythonPath = (script.extraContent as! ExtraContent).runtime ?? "/usr/bin/python"
    process.executableURL = URL(fileURLWithPath: pythonPath)
    let (inputPipe, outputPipe) = (Pipe(), Pipe())
    process.standardInput = inputPipe
    process.standardOutput = outputPipe
    switch runningMode {
    case .prepare(input: let input):
      inputPipe.fileHandleForWriting.write(try encode(input, .prettyPrinted))
    case .serve(choice: let choice):
      inputPipe.fileHandleForWriting.write(try encode(choice, .prettyPrinted))
    }
    inputPipe.fileHandleForWriting.closeFile()
    type(of: self).runningProcess = process
    try process.run()
    let runningResult = outputPipe.fileHandleForReading.readDataToEndOfFile()
    guard
      !runningResult.isEmpty
    else { return [] }
    let returned = try JSONSerialization.jsonObject(with: runningResult, options: .mutableLeaves)
    if let jsonObject = returned as? [Dictionary<String, Any>] {
      return jsonObject.compactMap { decode($0, withIcon: script.icon, extraInfo: script) }
    } else if let errorInfo = returned as? Dictionary<String, String> {
      #if DEBUG
      print(errorInfo)
      #endif
    }
    return []
  }
  
  // MARK: - TonnerreService functions
  
  /**
   Cached request key. Used to avoid duplicate writting and requesting from the Trie
  */
  private var cachedKey: String?
  /**
   Cached services.
  */
  private var cachedServices: [DisplayableContainer<String>] = []
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard input.count > 0 else { return [] }
    let queryKey = input.first!.lowercased()
    let possibleServices: [DisplayableContainer<String>]
    if let cache = cachedKey, cache == queryKey {
      possibleServices = cachedServices
    } else {
      cachedKey = queryKey
      possibleServices = serviceTrie.find(value: queryKey)
      cachedServices = possibleServices
    }
    if input.count > 1 {
      let queryContent = Array(input[1...])
      let task = DispatchWorkItem { [unowned self] in
        DynamicService.runningProcess?.terminate()
        let content = possibleServices.compactMap { try? self.execute(script: $0, runningMode: .prepare(input: queryContent)) }.reduce([], +)
        guard content.count > 0 else { return }
        let notification = Notification(name: .asyncLoadingDidFinish, object: self, userInfo: ["rawElements": content])
        NotificationCenter.default.post(notification)
      }
      asyncSession.send(request: task)
      var filledService = [DisplayableContainer<String>]()
      for var service in possibleServices {
        service.content = fill(template: service.content, withArguments: queryContent)
        filledService.append(service)
      }
      return filledService
    }
    return possibleServices
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
      let originalService: DisplayableContainer<String>
      if let urlResult = source as? DisplayableContainer<URL>,
        let service = urlResult.extraContent as? DisplayableContainer<String> {
        originalService = service
      } else if
        let anyResult = source as? DisplayableContainer<Any>,
        let service = anyResult.extraContent as? DisplayableContainer<String> {
        originalService = service
      } else { return }
      type(of: self).runningProcess?.terminate()
      var dictionarizedChoice = self.dictionarize(source)
      dictionarizedChoice["withCmd"] = withCmd
      do {
        _ = try self.execute(script: originalService, runningMode: .serve(choice: dictionarizedChoice))
      } catch {
        #if DEBUG
        print("Serve Error: ", error)
        #endif
      }
    }
  }
}

extension DynamicService: AsyncLoadingProtocol {
  var mode: AsyncLoadingType {
    return .replaced
  }
  
  func present(rawElements: [Any]) -> [ServiceResult] {
    guard rawElements is [DisplayProtocol] else { return [] }
    return (rawElements as! [DisplayProtocol]).map { ServiceResult(service: self, value: $0) }
  }
}
