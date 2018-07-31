//
//  DynamicWebService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class DynamicWebService: TonnerreService {
  static let keyword: String = ""
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  private var serviceTrie: Trie<DisplayableContainer<URL>>!
  private typealias ExtraContent = (keyword: String, argLowerBound: Int, argUpperBound: Int)
  
  func reload() {
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      let services = type(of: self).prefetch()
      self.serviceTrie = Trie(values: services) { ($0.extraContent! as! ExtraContent).keyword }
    }
  }
  
  required init() {
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      let services = type(of: self).prefetch()
      self.serviceTrie = Trie(values: services) { ($0.extraContent! as! ExtraContent).keyword }
    }
  }
  
  private static func loadImage(rawURL: String) -> NSImage {
    if rawURL.starts(with: "http") || rawURL.starts(with: "https") {
      let url = URL(string: rawURL)!
      return NSImage(contentsOf: url) ?? #imageLiteral(resourceName: "tonnerre")
    } else {
      let userDefault = UserDefaults.standard
      let appSupDir = userDefault.url(forKey: StoredKeys.appSupportDir.rawValue)!
      let desiredURL = URL(fileURLWithPath: rawURL, relativeTo: appSupDir)
      return NSImage(contentsOf: desiredURL) ?? #imageLiteral(resourceName: "tonnerre")
    }
  }
  
  private static func constructService(from json: Dictionary<String, Any>) -> DisplayableContainer<URL>? {
    guard
      let name = json["name"] as? String,
      let keyword = json["keyword"] as? String,
      let urlRaw = json["template"] as? String,
      let url = URL(string: urlRaw),
      let iconString = json["icon"] as? String
    else { return nil }
    let argLowerBound = json["argLowerBound"] as? Int ?? 1
    let argUpperBound = json["argUpperBound"] as? Int ?? argLowerBound
    let content = json["content"] as? String ?? ""
    let icon = loadImage(rawURL: iconString)
    return DisplayableContainer(name: name, content: content, icon: icon, innerItem: url, placeholder: name, extraContent: (keyword, argLowerBound, argUpperBound))
  }
  
  private static func generateService(from url: URL) -> [DisplayableContainer<URL>] {
    guard
      let jsonData = try? Data(contentsOf: url),
      let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves))
    else { return [] }
    if let singleJson = jsonObject as? Dictionary<String, Any>, let service = constructService(from: singleJson) {
      return [service]
    } else if let multipleJson = jsonObject as? [Dictionary<String, Any>] {
      return multipleJson.compactMap(constructService)
    }
    return []
  }
  
  private static func prefetch() -> [DisplayableContainer<URL>] {
    let appSupDir = UserDefaults.standard.url(forKey: StoredKeys.appSupportDir.rawValue)!
    let serviceFolder = appSupDir.appendingPathComponent("Services")
    do {
      let contents = try FileManager.default.contentsOfDirectory(at: serviceFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
      let extensions = contents.filter { $0.pathExtension.lowercased() == "json" } // Tonnerre Extension File Type
      return extensions.map(generateService).reduce([], +)
    } catch {
      #if DEBUG
      print("Error with loading: ", error)
      #endif
      return []
    }
  }
  
  func prepare(input: [String]) -> [Displayable] {
    return []
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    
  }
}
