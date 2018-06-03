//
//  GoogleSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct GoogleSearch: WebService {
  
  let icon: NSImage = #imageLiteral(resourceName: "google")
  let name: String = "Google"
  let content: String = "Search on google for what you want"
  let template: String = "https://google.com/search?q=%@"
  let suggestionTemplate: String = "https://suggestqueries.google.com/complete/search?client=safari&q=%@"
  let keyword: String = "google"
  let arguments: [String] = ["query"]
  let hasPreview: Bool = false
  let loadSuggestion: Bool
  
  init() {
    loadSuggestion = true
  }
  
  init(suggestion: Bool) {
    loadSuggestion = suggestion
  }
  
  func processJSON(data: Data?) -> [String: Any] {
    guard
      let jsonData = data,
      let json = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? NSArray,
      json.count > 2,
      let queriedWord = json[0] as? String,
      let availableOptions = json[1] as? [NSArray]
      else { return [:] }
    let suggestions = availableOptions.compactMap { $0[0] as? String }
    return ["suggestions": suggestions, "queriedWord": queriedWord, "queriedKey": keyword]
  }
}
