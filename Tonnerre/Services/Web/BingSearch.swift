//
//  BingSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct BingSearch: WebService {
  let name: String = "Bing"
  let template: String = "http://www.bing.%@/search?q=%@"
//  let suggestionTemplate: String = "https://suggestqueries.google.com/complete/search?client=safari&q=%@"
  let suggestionTemplate: String = "https://www.bing.com/AS/Suggestions?qry=%@&cvid=FE7921BDBFFB47FBBC57F3B4F078A12D"// May not be stable
  let contentTemplate: String = "Search %@ on bing"
  static let keyword: String = "bing"
  let loadSuggestion: Bool = true
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "bing")
  static var ongoinTask: URLSessionDataTask?
  
//  func processJSON(data: Data?) -> [String : Any] {
//    guard
//      let jsonData = data,
//      let json = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? NSArray,
//      json.count > 2,
//      let availableOptions = json[1] as? [NSArray]
//      else { return [:] }
//    let suggestions = availableOptions.compactMap { $0[0] as? String }
//    return ["suggestions": suggestions]
//  }
  
  func processJSON(data: Data?) -> [String : Any] {
    guard
      let htmlData = data,
      let html = String(data: htmlData, encoding: .utf8)
    else { return [:] }
    let keywordExtractor = try! NSRegularExpression(pattern: "\\/search\\?q=(.*?)&", options: .caseInsensitive)
    let matches = keywordExtractor.matches(in: html, options: .withoutAnchoringBounds, range: NSRange(location: 0, length: html.count))
    let ranges = matches.map { $0.range(at: 1) }
    let suggestions = ranges.compactMap { Range($0, in: html) }
      .map { String(html[$0]) }.compactMap { $0.removingPercentEncoding }
      .map { $0.replacingOccurrences(of: "+", with: " ") }
    return ["suggestions": suggestions]
  }
}
