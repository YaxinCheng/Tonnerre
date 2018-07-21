//
//  DynamicService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class DynamicService: TonnerreService {
  static let keyword: String = ""
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  private var scripts = Dictionary<String, [DisplayableContainer<String>]>()
  private var scriptTrie: Trie<(String, DisplayableContainer<String>)>
  private let encode = JSONSerialization.data
  
  // MARK: - Tool
  func decode(_ jsonObject: Dictionary<String, Any>, withIcon: NSImage) -> Displayable? {
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
      return DisplayableContainer(name: name, content: content, icon: withIcon, innerItem: urlItem, placeholder: placeholder)
    } else {
      return DisplayableContainer<Any>(name: name, content: content, icon: withIcon, innerItem: innerItem, placeholder: placeholder)
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
      let item = DisplayableContainer(name: name, content: descriptionObj["content"] ?? "", icon: icon, innerItem: script.path, placeholder: descriptionObj["placeholder"] ?? "")
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
  
  private func execute(script: DisplayableContainer<String>, runningMode: Mode) throws -> [Displayable] {
    guard let scriptPath = script.innerItem, FileManager.default.fileExists(atPath: scriptPath) else { return [] }
    let process = Process()
    process.arguments = [runningMode.argument, scriptPath]
    process.executableURL = Bundle.main.url(forResource: "DynamicServiceExec", withExtension: "py")
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
    try process.run()
    let runningResult = outputPipe.fileHandleForReading.readDataToEndOfFile()
    guard
      !runningResult.isEmpty
    else { return [] }
    let returned = try JSONSerialization.jsonObject(with: runningResult, options: .mutableLeaves)
    if let jsonObject = returned as? [Dictionary<String, Any>] {
      return jsonObject.compactMap { decode($0, withIcon: script.icon) }
    } else if let errorInfo = returned as? Dictionary<String, String> {
      #if DEBUG
      print(errorInfo)
      #endif
    }
    return []
  }
  
  // MARK: - TonnerreService
  
  func prepare(input: [String]) -> [Displayable] {
    guard input.count > 0 else { return [] }
    let queryKey = input.first!
    let possibleServices = scriptTrie.find(value: queryKey).map { $0.1 }
    guard input.count > 1 else { return possibleServices }
    let queryContent = Array(input[1...])
    let preparedResult = possibleServices.compactMap { try? execute(script: $0, runningMode: .prepare(input: queryContent)) }
    return zip(possibleServices, preparedResult).map { value in
      value.1.map { DynamicServiceBound(service: value.0, result: $0) }
    }.reduce([], +)
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let dynService = source as? DynamicServiceBound else { return }
    let (service, choice) = (dynService.service, dynService.result)
    var dictionarizedChoice = dictionarize(choice)
    dictionarizedChoice["withCmd"] = withCmd
    do {
      _ = try execute(script: service, runningMode: .serve(choice: dictionarizedChoice))
    } catch {
      #if DEBUG
      print("Serve Error: ", error)
      #endif
    }
  }
}


