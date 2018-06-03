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
  let template: String = "https://en.wikipedia.org/wiki/%@"
  let suggestionTemplate: String = "https://en.wikipedia.org//w/api.php?action=opensearch&format=json&formatversion=2&search=%@&namespace=0&limit=10&suggest=true"
  let content: String = "Search on Wikipedia for your knowledge"
  let keyword: String = "wiki"
  let arguments: [String] = ["query"]
  let hasPreview: Bool = false
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
