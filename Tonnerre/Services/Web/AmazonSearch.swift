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
  let contentTemplate: String = "Shopping %@ on amazon"
  let keyword: String = "amazon"
  let minTriggerNum: Int = 1
  let hasPreview: Bool = false
  let acceptsInfiniteArguments: Bool = true
  let loadSuggestion: Bool
  
  init() {
    loadSuggestion = true
  }
  
  init(suggestion: Bool) {
    loadSuggestion = suggestion
  }

  func processJSON(data: Data?) -> [String : Any] {
    guard
      let jsonData = data,
      let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? NSArray,
      let queriedWord = jsonObject[0] as? String,
      let suggestions = jsonObject[1] as? [String]
    else { return [:] }
    return ["suggestions": suggestions, "queriedWord": queriedWord, "queriedKey": keyword]
  }
}
