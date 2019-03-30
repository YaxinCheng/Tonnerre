//
//  WikipediaSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct WikipediaSearch: WebService {
  let icon: NSImage = #imageLiteral(resourceName: "wikipedia")
  let name: String = "Wikipedia"
  let contentTemplate: String = "Search \"%@\" on Wikipedia"
  let keyword: String = "wiki"
  let argLowerBound: Int = 1
  let argUpperBound: Int = .max
  
  func parse(suggestionData: Data?) -> [String] {
    guard
      let jsonData = suggestionData,
      let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? NSArray,
      let suggestions = jsonObject[1] as? [String]
      else { return [] }
    return suggestions
  }
}
