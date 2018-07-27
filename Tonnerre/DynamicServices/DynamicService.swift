//
//  DynamicService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class DynamicService: TonnerreService, AsyncLoadingProtocol {
  static let keyword: String = ""
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  private var scripts = Dictionary<String, [DisplayableContainer<String>]>()
  private var scriptTrie: Trie<(String, DisplayableContainer<String>)>
  private let encode = JSONSerialization.data
  private let suggestionSession = TonnerreSuggestionSession.shared
  let mode: LoadingMode = .replaced
  
  // MARK: - Tool
  func decode(_ jsonObject: Dictionary<String, Any>, withIcon: NSImage, extraInfo: Any? = nil) -> Displayable? {
    guard
      let rawName = jsonObject["name"]
    else { return nil }
    let name: String = "\(rawName)"
    let content = jsonObject["content"] as? String ?? ""
    let innerItem = jsonObject["innerItem"]
    let placeholder = jsonObject["placeholder"] as? String ?? ""
    if
      let stringItem = innerItem as? String,
      let urlItem = URL(string: stringItem),
      let _ = NSWorkspace.shared.urlForApplication(toOpen: urlItem) {
      return DisplayableContainer(name: name, content: content, icon: withIcon, innerItem: urlItem, placeholder: placeholder, extraContent: extraInfo)
    } else {
      return DisplayableContainer<Any>(name: name, content: content, icon: withIcon, innerItem: innerItem, placeholder: placeholder, extraContent: extraInfo)
    }
  }
  
  func dictionarize(_ displayItem: Displayable) -> Dictionary<String, Any> {
    var resultDictionary = Dictionary<String, Any>()
    resultDictionary["name"] = displayItem.name
    resultDictionary["content"] = displayItem.content
    resultDictionary["placeholder"] = displayItem.placeholder
    if let urlContent = (displayItem as? DisplayableContainer<URL>)?.innerItem {
      resultDictionary["innerItem"] = urlContent.absoluteString
    } else {
      resultDictionary["innerItem"] = (displayItem as? DisplayableContainer<Any>)?.innerItem
    }
    return resultDictionary
  }

  // MARK: - Constructions
  
  /**
   Parse information in a json file to get the service
   - parameter url: the url to the TNE script
   - returns: (keyword, DisplayableContainer with information in the JSON)
  */
  private static func generateService(from url: URL) -> (String, DisplayableContainer<String>)? {
    let script = url.appendingPathComponent("main.py")
    guard FileManager.default.fileExists(atPath: script.path) else { return nil }
    let iconURL = url.appendingPathComponent("icon.png")
    let icon = NSImage(contentsOf: iconURL) ?? #imageLiteral(resourceName: "tonnerre")
    let jsonURL = url.appendingPathComponent("description.json")
    do {
      let jsonData = try Data(contentsOf: jsonURL)
      let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? Dictionary<String, String>
      guard
        let descriptionObj = jsonObject,
        let name = descriptionObj["name"],
        let keyword = descriptionObj["keyword"]
      else { return nil }
      let pythonRuntime: String? = descriptionObj["runtime"] ?? nil
      let item = DisplayableContainer(name: name, content: descriptionObj["content"] ?? "", icon: icon, innerItem: script.path, placeholder: descriptionObj["placeholder"] ?? "", extraContent: pythonRuntime)
      return (keyword, item)
    } catch {
      #if DEBUG
      print("Error happened in generate service: ", error)
      #endif
      return nil
    }
  }
  
  /**
   Load TNE extensions from the Services folder in the App Support
   - returns: An array of available services, where as the first value is the keyword, and second is how to display it
  */
  private static func prefetch() -> [(String, DisplayableContainer<String>)] {
    let appSupDir = UserDefaults.standard.url(forKey: StoredKeys.appSupportDir.rawValue)!
    let serviceFolder = appSupDir.appendingPathComponent("Services")
    do {
      let contents = try FileManager.default.contentsOfDirectory(at: serviceFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
      let extensions = contents.filter { $0.pathExtension.lowercased() == "tne" } // Tonnerre Extension File Type
      return extensions.compactMap(generateService)
    } catch {
      #if DEBUG
      print("Error with loading: ", error)
      #endif
      return []
    }
  }
  
  required init() {
    let scripts = DynamicService.prefetch()
    scriptTrie = Trie(values: scripts) { $0.0 }
  }
  
  func reload() {
    let scripts = DynamicService.prefetch()
    scriptTrie = Trie(values: scripts) { $0.0 }
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
  
  private func execute(script: DisplayableContainer<String>, runningMode: Mode) throws -> [Displayable] {
    guard let scriptPath = script.innerItem, FileManager.default.fileExists(atPath: scriptPath) else { return [] }
    let process = Process()
    process.arguments = [Bundle.main.url(forResource: "DynamicServiceExec", withExtension: "py")!.path, runningMode.argument, scriptPath]
    let pythonPath = (script.extraContent as? String) ?? "/usr/bin/python"
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
  
  // MARK: - TonnerreService
  
  /**
   Cached request key. Used to avoid duplicate writting and requesting from the Trie
  */
  private var cachedKey: String?
  /**
   Cached services.
  */
  private var cachedServices: [DisplayableContainer<String>] = []
  
  func prepare(input: [String]) -> [Displayable] {
    guard input.count > 0 else { return [] }
    let queryKey = input.first!.lowercased()
    let possibleServices: [DisplayableContainer<String>]
    if let cache = cachedKey, cache == queryKey {
      possibleServices = cachedServices
    } else {
      cachedKey = queryKey
      possibleServices = scriptTrie.find(value: queryKey).map { $0.1 }
      cachedServices = possibleServices
    }
    if input.count > 1 {
      let queryContent = Array(input[1...])
      let task = DispatchWorkItem { [unowned self] in
        DynamicService.runningProcess?.terminate()
        let content = possibleServices.compactMap { try? self.execute(script: $0, runningMode: .prepare(input: queryContent)) }.reduce([], +)
        guard content.count > 0 else { return }
        let notification = Notification(name: .suggestionDidFinish, object: self, userInfo: ["suggestions": content])
        NotificationCenter.default.post(notification)
      }
      suggestionSession.send(request: task)
      var filledService = [DisplayableContainer<String>]()
      for var service in possibleServices {
        service.content = fill(template: service.content, withArguments: queryContent)
        filledService.append(service)
      }
      return filledService
    }
    return possibleServices
  }
  
  func serve(source: Displayable, withCmd: Bool) {
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
  
  private func fill(template: String, withArguments args: [String]) -> String {
    let placeholderCount = template.components(separatedBy: "%@").count - 1
    guard placeholderCount <= args.count else { return template }
    if placeholderCount == args.count {
      return String(format: template, arguments: args)
    } else {
      let lastArg = args[placeholderCount...].joined(separator: " ")
      let fillInArgs = Array(args[..<placeholderCount]) + [lastArg]
      return String(format: template, arguments: fillInArgs)
    }
  }
  
  func present(suggestions: [Any]) -> [ServiceResult] {
    guard suggestions is [Displayable] else { return [] }
    return (suggestions as! [Displayable]).map { ServiceResult(service: self, value: $0) }
  }
}


