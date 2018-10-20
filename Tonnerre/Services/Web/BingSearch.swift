//
//  BingSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct BingSearch: WebService {
  let name: String = "Bing"
  let template: String = "http://www.bing.com/search?q=%@"
  let suggestionTemplate: String = "https://www.bing.com/AS/Suggestions?qry=%@&cvid=FE7921BDBFFB47FBBC57F3B4F078A12D"// May not be stable
  let contentTemplate: String = "Search %@ on bing"
  static let keyword: String = "bing"
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
