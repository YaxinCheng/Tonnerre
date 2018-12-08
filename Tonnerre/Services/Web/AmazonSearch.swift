//
//  AmazonSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct AmazonSearch: WebService {
  let icon: NSImage = #imageLiteral(resourceName: "amazon")
  let name: String = "Amazon"
  let template: String = "https://www.amazon.%@/s/?field-keywords=%@"
  let suggestionTemplate: String = "https://completion.amazon.com/search/complete?search-alias=aps&client=amazon-search-ui&mkt=1&q=%@"
  let contentTemplate: String = "Shopping \"%@\" on Amazon"
  let keyword: String = "amazon"
  let argLowerBound: Int = 1
  let argUpperBound: Int = .max

  func parse(suggestionData: Data?) -> [String] {
    guard
      let jsonData = suggestionData,
      let jsonObject = JSON(data: jsonData),
      let suggestions: [String] = jsonObject[1]
    else { return [] }
    return suggestions
  }
}
