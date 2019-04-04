//
//  BingSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

// NOTE: The suggestionTemplate may not be stable in the future
struct BingSearch: WebService {
  let name: String = "Bing"
  let contentTemplate: String = "Search \"%@\" on Bing"
  let defaultKeyword: String = "bing"
  let argLowerBound: Int = 1
  let argUpperBound: Int = .max
  let icon: NSImage = #imageLiteral(resourceName: "bing")
  
  func parse(suggestionData: Data?) -> [String] {
    guard
      let htmlData = suggestionData,
      let html = String(data: htmlData, encoding: .utf8)
    else { return [] }
    let keywordExtractor = try! NSRegularExpression(pattern: "\\/search\\?q=(.*?)&", options: .caseInsensitive)
    let matches = keywordExtractor.matches(in: html, options: .withoutAnchoringBounds, range: NSRange(location: 0, length: html.count))
    let ranges = matches.map { $0.range(at: 1) }
    return ranges.compactMap { Range($0, in: html) }
      .map { String(html[$0]) }.map { $0.replacingOccurrences(of: "+", with: " ") }
      .compactMap { $0.removingPercentEncoding }
  }
}
