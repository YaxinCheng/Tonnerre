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
  
  // MARK: - Tool functions
  private func encode(array: [String]) throws -> Data {
    return try JSONSerialization.data(withJSONObject: array, options: .prettyPrinted)
  }
  
  // MARK: - Constructions
  
  private static func generateService(from url: URL) -> (String, DisplayableContainer<String>)? {
    let script = url.appendingPathComponent("main.py")
    guard FileManager.default.fileExists(atPath: script.path) else { return nil }
    let iconURL = url.appendingPathComponent("icon")
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
  
  private static func load() -> [(String, DisplayableContainer<String>)] {
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
    let scripts = DynamicService.load()
    scriptTrie = Trie(values: scripts) { $0.0 }
  }
  
  // MARK: - Script Execute
  private enum Mode {
    case prepare
    case serve
  }
  
  private func execute(script: DisplayableContainer<String>, runningMode: Mode) -> [Displayable] {
    guard let scriptPath = script.innerItem, FileManager.default.fileExists(atPath: scriptPath) else { return [] }
    let process = Process()
    // Launch default python script to execute
    return []
  }
  
  // MARK: - TonnerreService
  
  func prepare(input: [String]) -> [Displayable] {
    do {
      guard input.count > 0 else { return [] }
      let queryKey = input.first!
      let possibleServices = scriptTrie.find(value: queryKey)
      guard input.count > 1 else { return possibleServices.map { $0.1 } }
      let queryContent = Array(input[1...])
      let encodedContent = try encode(array: queryContent)
      
    } catch {
      
    }
    return []
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    
  }
}
