//
//  BookmarksService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-18.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

/**
 A protocol for loading bookmarks from safari and chrome
*/
protocol BookMarkService: TonnerreService {
  /**
   Type of bookmark
  */
  typealias BookMark = (title: String, url: URL)
  /**
   The path to where the bookmark file is located
  */
  var bookmarksFile: URL { get }
  /**
   Read bookmarks data from the browser's file
   
   - returns: an array of bookmarks without grouping
  */
  func parseFile() -> [BookMark]
}

extension BookMarkService {
  var argLowerBound: Int { return 1 }
  var argUpperBound: Int { return Int.max }
  
  func prepare(input: [String]) -> [Displayable] {
    let bookMarks = parseFile()
    let regex = try! NSRegularExpression(pattern: ".*?\(input.joined(separator: ".*?")).*?", options: .caseInsensitive)
    let filteredBMs = bookMarks.filter {
      regex.numberOfMatches(in: $0.title, options: .withoutAnchoringBounds, range: NSRange($0.title.startIndex..<$0.title.endIndex, in: $0.title)) >= 1
    }
    return filteredBMs.map { DisplayableContainer(name: $0.title, content: $0.url.absoluteString, icon: icon, innerItem: $0.url, placeholder: $0.title) }
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let innerItem = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    NSWorkspace.shared.open(innerItem)
  }
}
