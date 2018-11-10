//
//  WebExt.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct WebExt: DisplayProtocol {
  let name: String
  var content: String
  let icon: NSImage
  var placeholder: String
  let keyword: String
  var rawURL: String
  let argLowerBound: Int
  let argUpperBound: Int
  let priority: DisplayPriority
  private let attrName: String
  var id: String {
    return attrName
  }
  
  init(keyword: String, name: String, content: String, icon: NSImage, rawURL: String, attrName: String, lowerBound: Int, upperBound: Int, placeholder: String? = nil, priority: DisplayPriority = .normal) {
    self.keyword = keyword
    self.name = name
    self.content = content
    self.icon = icon
    self.attrName = attrName
    self.rawURL = rawURL
    self.argLowerBound = lowerBound
    self.argUpperBound = upperBound
    self.placeholder = placeholder ?? keyword
    self.priority = priority
  }
  
  private static func loadImage(rawURL: String) -> NSImage {
    if rawURL.starts(with: "https://") {// If it's http url, send sync request to load
      let url = URL(string: rawURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
      let request = URLRequest(url: url, timeoutInterval: 60 * 60 * 24)
      var image: NSImage = #imageLiteral(resourceName: "notFound")
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
      let appSupDir = userDefault.url(forKey: .appSupportDir)!
      let desiredURL = URL(fileURLWithPath: rawURL, relativeTo: appSupDir)
      return NSImage(contentsOf: desiredURL) ?? #imageLiteral(resourceName: "tonnerre_extension")
    }
  }
  
  static func construct(fromURL url: URL) -> [WebExt] {
    guard url.pathExtension == "json" else { return [] }
    do {
      let jsonData = try Data(contentsOf: url)
      if let jsonObject = JSON(data: jsonData) {
        var validExts = [WebExt]()
        for (attrName, json) in jsonObject {
          guard
            case .string(let attributeName) = attrName,
            let jsonContent = json as? [String: Any],
            let name = jsonContent["name"] as? String,
            let keyword = jsonContent["keyword"] as? String,
            let rawURL = jsonContent["url"] as? String
          else { continue }
          let content = jsonContent["content"] as? String ?? ""
          let argLowerBound = jsonContent["argLowerBound"] as? Int ?? 1
          let argUpperBound = jsonContent["argUpperBound"] as? Int ?? .max
          let priorityStr = jsonContent["priority"] as? String
          let priority = DisplayPriority(rawValue: priorityStr ?? "") ?? .normal
          let icon = jsonContent["icon"] is String ? loadImage(rawURL: jsonContent["icon"] as! String) : #imageLiteral(resourceName: "notFound")
          let loadedExt = WebExt(keyword: keyword, name: name, content: content, icon: icon, rawURL: rawURL, attrName: attributeName, lowerBound: argLowerBound, upperBound: argUpperBound, priority: priority)
          validExts.append(loadedExt)
        }
        return validExts
      } else { return [] }
    } catch {
      #if DEBUG
      print("Webext construct error", error)
      #endif
      return []
    }
  }
}

extension WebExt: Hashable {
  var hashValue: Int {
    return id.hashValue
  }
  
  static func == (lhs: WebExt, rhs: WebExt) -> Bool {
    return lhs.id == rhs.id
  }
}
