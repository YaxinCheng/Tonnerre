//
//  DynamicWebService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class DynamicWebService: TonnerreService, DynamicProtocol {
  static let keyword: String = ""
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  var icon: NSImage {
    return #imageLiteral(resourceName: "extension").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  var serviceTrie: Trie<ServiceType>
  internal typealias ExtraContent = (keyword: String, argLowerBound: Int, argUpperBound: Int)
  
  func reload() {
    serviceTrie = Trie(values: []) { ($0.extraContent! as! ExtraContent).keyword }
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      self.prefetch(fileExtension: "json")
    }
  }
  
  required init() {
    serviceTrie = Trie(values: []) { ($0.extraContent! as! ExtraContent).keyword }
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      self.prefetch(fileExtension: "json")
    }
  }
  
  private static func loadImage(rawURL: String) -> NSImage {
    if rawURL.starts(with: "http") || rawURL.starts(with: "https") {// If it's http url, send sync request to load
      let url = URL(string: rawURL)!
      let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60 * 60 * 24)
      var image: NSImage = #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
      let asyncSemaphore = DispatchSemaphore(value: 0)
      URLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
        defer { asyncSemaphore.signal() }
        guard let imageData = data, let loadedImg = NSImage(data: imageData) else {
          #if DEBUG
          if error != nil { print(error!) }
          #endif
          return
        }
        image = loadedImg
      }.resume()
      _ = asyncSemaphore.wait(timeout: .distantFuture)
      return image
    } else {// Load from file
      let userDefault = UserDefaults.standard
      let appSupDir = userDefault.url(forKey: StoredKeys.appSupportDir.rawValue)!
      let desiredURL = URL(fileURLWithPath: rawURL, relativeTo: appSupDir)
      return NSImage(contentsOf: desiredURL) ?? #imageLiteral(resourceName: "extension").tintedImage(with: TonnerreTheme.current.imgColour)
    }
  }
  
  private static func process(json: Dictionary<String, Any>) -> ServiceType? {
    guard
      let name = json["name"] as? String,
      let keyword = json["keyword"] as? String,
      let urlRaw = json["template"] as? String,
      let iconString = json["icon"] as? String
    else { return nil }
    let argLowerBound = json["argLowerBound"] as? Int ?? 1
    let argUpperBound = json["argUpperBound"] as? Int ?? argLowerBound
    let content = json["content"] as? String ?? ""
    let icon = loadImage(rawURL: iconString)
    return DisplayableContainer(name: name, content: content, icon: icon, innerItem: urlRaw, placeholder: keyword, extraContent: (keyword, argLowerBound, argUpperBound))
  }
  
  static func generateService(from url: URL) -> [ServiceType] {
    guard
      let jsonData = try? Data(contentsOf: url),
      let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves))
    else { return [] }
    if let singleJson = jsonObject as? Dictionary<String, Any>, let service = process(json: singleJson) {
      return [service]
    } else if let multipleJson = jsonObject as? [Dictionary<String, Any>] {
      return multipleJson.compactMap(process)
    }
    return []
  }
  
  // MARK: - Tonnerre Service functions
  
  private var cachedKey: String?
  private var cachedServices: [ServiceType] = []
  
  func prepare(input: [String]) -> [Displayable] {
    guard input.count > 0 else { return [] }
    let queryKey = input.first!.lowercased()
    let possibleServices: [ServiceType]
    if let cache = cachedKey, cache == queryKey {
      possibleServices = cachedServices
    } else {
      cachedKey = queryKey
      possibleServices = serviceTrie.find(value: queryKey)
      cachedServices = possibleServices
    }
    if input.count > 1 {
      let queryContent = Array(input[1...])
      let servicesInRange = possibleServices.filter {
        let serviceExtra = $0.extraContent! as! ExtraContent
        return serviceExtra.argLowerBound <= input.count - 1 && serviceExtra.argUpperBound >= input.count - 1
      }
      return servicesInRange.compactMap {
        let filledURL = fill(template: $0.innerItem!, withArguments: queryContent)
        let filledContent = fill(template: $0.content, withArguments: queryContent)
        guard let url = URL(string: filledURL) else { return nil }
        return DisplayableContainer(name: $0.name, content: filledContent, icon: $0.icon, innerItem: url, placeholder: $0.name)
      }
    }
    return possibleServices
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    let workspace = NSWorkspace.shared
    if let url = (source as? DisplayableContainer<URL>)?.innerItem {
      workspace.open(url)
    } else if let rawURL = (source as? DisplayableContainer<String>)?.innerItem,
      let url = URL(string: rawURL),
      let _ = workspace.urlForApplication(toOpen: url) {
      workspace.open(url)
    }
  }
}
