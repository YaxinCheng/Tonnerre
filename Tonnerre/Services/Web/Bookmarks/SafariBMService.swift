//
//  SafariBMService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct SafariBMService: BookMarkService {
  static var browserURL: URL? {
    let safariURL = URL(fileURLWithPath: "/Applications/Safari.app")
    if FileManager.default.fileExists(atPath: safariURL.path) { return safariURL }
    else { return nil }
  }
  let bookmarksFile: URL?
  let name: String = "Safari BookMarks"
  let content: String = "Quick launch Safari Bookmarks"
  let icon: NSImage = .safari
  static let keyword: String = "safari"
  
  func parseFile() -> [BookMarkService.BookMark] {
    guard
      let bmFile = bookmarksFile,
      let plist = NSDictionary(contentsOf: bmFile) as? Dictionary<String, Any>
    else { return [] }
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
  
  init() {
    if SafariBMService.browserURL != nil {
      let homeDir = FileManager.default.homeDirectoryForCurrentUser
      bookmarksFile = homeDir.appendingPathComponent("/Library/Safari/Bookmarks.plist")
    } else { bookmarksFile = nil }
  }
}
