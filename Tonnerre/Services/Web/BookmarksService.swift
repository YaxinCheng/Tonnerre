//
//  BookmarksService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-18.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct BookmarksService: TonnerreService {
  static let keyword: String = "bookmarks"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "safari")
  private let bookmarksFile: URL
  private typealias BookMark = (title: String, url: URL, previewText: String)
  
  init() {
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    bookmarksFile = homeDir.appendingPathComponent("/Library/Safari/Bookmarks.plist")
  }
  
  private func parse(plist: Dictionary<String, Any>) -> [BookMark] {
    if (plist["WebBookmarkType"] as? String) == "WebBookmarkTypeList" {
      guard let children = plist["Children"] as? [Dictionary<String, Any>] else { return [] }
      return children.map { parse(plist: $0) }.reduce([], +)
    } else if (plist["WebBookmarkType"] as? String) == "WebBookmarkTypeLeaf" {
      guard
        let URLString = plist["URLString"] as? String,
        let url = URL(string: URLString),
        let title = (plist["URIDictionary"] as? Dictionary<String, String>)?["title"]
      else { return [] }
      return [(title, url, (plist["previewText"] as? String) ?? "")]
    } else { return [] }
  }
  
  func prepare(input: [String]) -> [Displayable] {
    guard
      let bookMarkDict = NSDictionary(contentsOfFile: bookmarksFile.path) as? Dictionary<String, Any>
    else { return [] }
    let bookMarks = parse(plist: bookMarkDict)
    let regex = try! NSRegularExpression(pattern: "(\(input.joined(separator: "|")))", options: .caseInsensitive)
    let filteredBms = bookMarks.filter {
      regex.numberOfMatches(in: $0.title, options: .withoutAnchoringBounds, range: NSRange($0.title.startIndex..<$0.title.endIndex, in: $0.title)) >= input.count
    }
    return filteredBms.map { DisplayableContainer(name: $0.title, content: $0.url.absoluteString, icon: icon, innerItem: $0.url, placeholder: $0.title) }
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let innerItem = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    NSWorkspace.shared.open(innerItem)
  }
}
