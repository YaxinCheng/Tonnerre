//
//  ChromeBMService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ChromeBMService: BookMarkService {
  typealias rawDataType = Dictionary<String, Any>
  let icon: NSImage = #imageLiteral(resourceName: "chrome")
  let name: String = "Chrome BookMarks"
  let content: String = "Quick launch Chrome Bookmarks"
  let bookmarksFile: URL?
  static var browserURL: URL? {
    let fileManager = FileManager.default
    let userDir = fileManager.homeDirectoryForCurrentUser
    let possibleURL = [URL(fileURLWithPath: "/Applications/Google Chrome.app"), userDir.appendingPathComponent("Applications/Google Chrome.app")]
    for url in possibleURL where fileManager.fileExists(atPath: url.path) {
      return url
    }
    return nil
  }
  static let keyword: String = "chrome"
  
  func parseFile() -> [BookMarkService.BookMark] {
    do {
      guard let bmFile = bookmarksFile else { return [] }
      let jsonData = try Data(contentsOf: bmFile)
      let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
      guard let bookmarkSource = jsonObject as? Dictionary<String, Any> else { return [] }
      return parse(rawFile: bookmarkSource)
    } catch {
      #if DEBUG
      print(error)
      #endif
      return []
    }
  }
  
  private func parse(rawFile: Dictionary<String, Any>) -> [BookMarkService.BookMark] {
    if let root = rawFile["roots"] as? Dictionary<String, Any> {
      return parse(rawFile: root)
    } else {
      return rawFile.compactMap { (_, value) -> [BookMark] in
        guard
          let children = (value as? Dictionary<String, Any>)?["children"] as? [Dictionary<String, Any>]
        else { return [] }
        return children.compactMap {
          guard
            let name = $0["name"] as? String,
            let URLString = $0["url"] as? String,
            let url = URL(string: URLString)
          else { return nil }
          return (name, url) as BookMark
        }
      }.reduce([], +)
    }
  }
  
  init() {
    if ChromeBMService.browserURL != nil {
      let appSupDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
      bookmarksFile = appSupDir.appendingPathComponent("Google/Chrome/Default/Bookmarks")
    } else {
      bookmarksFile = nil
    }
  }
}
