//
//  ChromeBMService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ChromeBMService: BookMarkService, DeferedServiceProtocol {
  typealias rawDataType = Dictionary<String, Any>
  let name: String = "Chrome BookMarks"
  let content: String = "Quick launch Chrome Bookmarks"
  static let keyword: String = "chrome"
  static let browser: Browser = .chrome
  
  func parseFile() throws -> [BookMarkService.BookMark] {
    guard let bmFile = type(of: self).browser.bookMarksFile else { return [] }
    let jsonData = try Data(contentsOf: bmFile)
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
    guard let bookmarkSource = jsonObject as? Dictionary<String, Any> else { return [] }
    return parse(rawFile: bookmarkSource)
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
}
