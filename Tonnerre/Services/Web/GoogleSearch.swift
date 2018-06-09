//
//  GoogleSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol Google: WebService {
}

extension Google {
  var icon: NSImage { return #imageLiteral(resourceName: "google") }
  var suggestionTemplate: String {
    return "https://suggestqueries.google.com/complete/search?client=safari&q=%@"
  }
  var minTriggerNum: Int { return 1 }
  var hasPreview: Bool { return false }
  var loadSuggestion: Bool { return true }
  var acceptsInfiniteArguments: Bool { return true }
  
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

struct GoogleSearch: Google {
  let name: String = "Google"
  let contentTemplate: String = "Search %@ on google"
  let template: String = "https://google.%@/search?q=%@"
  let keyword: String = "google"
  let loadSuggestion: Bool
  init() {
    loadSuggestion = true
  }
  init(suggestion: Bool) {
    loadSuggestion = suggestion
  }
}

struct GoogleImageSearch: Google {
  let name: String = "Google Images"
  let contentTemplate: String = "Search %@ on google image"
  let template: String = "https://google.%@/search?q=%@&tbm=isch"
  let keyword: String = "image"
}

struct YoutubeSearch: Google {
  let suggestionTemplate: String = "https://clients1.google.com/complete/search?client=safari&q=%@"
  let name: String = "Youtube"
  let contentTemplate: String = "Find %@ on Youtube"
  let template: String = "https://www.youtube.com/results?search_query=%@"
  let keyword: String = "youtube"
  let icon: NSImage = #imageLiteral(resourceName: "youtube")
}
