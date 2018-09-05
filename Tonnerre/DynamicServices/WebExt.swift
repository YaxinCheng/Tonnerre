//
//  WebExt.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class WebExt: DisplayProtocol {
  let name: String
  var content: String
  let icon: NSImage
  var placeholder: String
  let keyword: String
  var url: URL
  let argLowerBound: Int
  let argUpperBound: Int
  private let path: URL
  private let attrName: String
  var id: String {
    return path.path + "//" + attrName
  }
  
  init(keyword: String, name: String, content: String, icon: NSImage, url: URL, path: URL, attrName: String, lowerBound: Int, upperBound: Int, placeholder: String? = nil) {
    self.keyword = keyword
    self.name = name
    self.content = content
    self.icon = icon
    self.path = path
    self.attrName = attrName
    self.url = url
    self.argLowerBound = lowerBound
    self.argUpperBound = upperBound
    self.placeholder = placeholder ?? keyword
  }
  
  private static func loadImage(rawURL: String) -> NSImage {
    if rawURL.starts(with: "http") || rawURL.starts(with: "https") {// If it's http url, send sync request to load
      let url = URL(string: rawURL)!
      let request = URLRequest(url: url, timeoutInterval: 60 * 60 * 24)
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
      let appSupDir = userDefault.url(forKey: .appSupportDir)!
      let desiredURL = URL(fileURLWithPath: rawURL, relativeTo: appSupDir)
      return NSImage(contentsOf: desiredURL) ?? #imageLiteral(resourceName: "tonnerre_extension").tintedImage(with: TonnerreTheme.current.imgColour)
    }
  }
  
  static func construct(fromURL url: URL) -> [WebExt] {
    guard url.pathExtension == "json" else { return [] }
    do {
      let jsonData = try Data(contentsOf: url)
      if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
      as? Dictionary<String, [String: Any]> {
        var validExts = [WebExt]()
        for (attrName, jsonContent) in jsonObject {
          guard
            let name = jsonContent["name"] as? String,
            let keyword = jsonContent["keyword"] as? String,
            let rawURL = jsonContent["url"] as? String,
            let url = URL(string: rawURL)
          else { continue }
          let content = jsonContent["content"] as? String ?? ""
          let argLowerBound = jsonContent["argLowerBound"] as? Int ?? 1
          let argUpperBound = jsonContent["argUpperBound"] as? Int ?? argLowerBound
          let icon = jsonContent["icon"] is String ? loadImage(rawURL: jsonContent["icon"] as! String) : #imageLiteral(resourceName: "notFound")
          let loadedExt = WebExt(keyword: keyword, name: name, content: content, icon: icon, url: url, path: url, attrName: attrName, lowerBound: argLowerBound, upperBound: argUpperBound)
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
