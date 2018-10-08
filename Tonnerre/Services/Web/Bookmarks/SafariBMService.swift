//
//  SafariBMService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct SafariBMService: BookMarkService, DeferedServiceProtocol {
  static let browser: Browser = .safari
  let name: String = "Safari BookMarks"
  let content: String = "Quick launch Safari Bookmarks"
  static let keyword: String = "safari"
  
  func parseFile() -> [BookMarkService.BookMark] {
    guard
      let bookmarkFile = type(of: self).browser.bookMarksFile,
      let plist = NSDictionary(contentsOf: bookmarkFile) as? Dictionary<String, Any>
    else {
      let errorTitle = "Error Loading Safari Bookmarks"
      let errorDescr = """
Failed to load Safari Bookmarks due to: Denied of Permission

Please add `Tonnerre.app` to System Preference - Security & Privacy - Full Disk Access

After restarting the app, the bookmarks should be loaded
"""
      LocalNotification.send(title: errorTitle, content: errorDescr)
      return []
    }
    return parse(plist: plist)
  }
  
  private func parse(plist: Dictionary<String, Any>) -> [BookMarkService.BookMark] {
    if (plist["WebBookmarkType"] as? String) == "WebBookmarkTypeList" {
      guard let children = plist["Children"] as? [Dictionary<String, Any>] else { return [] }
      return children.map { parse(plist: $0) }.reduce([], +)
    } else if (plist["WebBookmarkType"] as? String) == "WebBookmarkTypeLeaf" {
      guard
        let URLString = plist["URLString"] as? String,
        let url = URL(string: URLString),
        let title = (plist["URIDictionary"] as? Dictionary<String, String>)?["title"]
      else { return [] }
      return [(title, url)]
    } else { return [] }
  }
}
