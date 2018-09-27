//
//  WikipediaSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct WikipediaSearch: WebService {
  let icon: NSImage = #imageLiteral(resourceName: "wikipedia")
  let name: String = "Wikipedia"
  let template: String = "https://en.m.wikipedia.org/wiki/%@"
  let suggestionTemplate: String = "https://en.wikipedia.org//w/api.php?action=opensearch&format=json&formatversion=2&search=%@&namespace=0&limit=10&suggest=true"
  let contentTemplate: String = "Search %@ on Wikipedia"
  static let keyword: String = "wiki"
  let argLowerBound: Int = 1
  let argUpperBound: Int = .max
  
  func parse(suggestionData: Data?) -> [String : Any] {
    guard
      let jsonData = suggestionData,
      let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? NSArray,
      let suggestions = jsonObject[1] as? [String]
      else { return [:] }
    return ["rawElements": suggestions]
  }
}
