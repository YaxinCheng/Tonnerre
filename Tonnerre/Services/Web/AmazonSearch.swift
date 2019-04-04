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
  let contentTemplate: String = "Shop \"%@\" on Amazon"
  let defaultKeyword: String = "amazon"
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
