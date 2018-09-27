//
//  GoogleSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol Google: WebService {
}

extension Google {
  var icon: NSImage { return #imageLiteral(resourceName: "google") }
  var suggestionTemplate: String {
    return "https://suggestqueries.google.com/complete/search?client=safari&q=%@"
  }
  var argLowerBound: Int { return 1 }
  var argUpperBound: Int { return .max }
  
  func parse(suggestionData: Data?) -> [String: Any] {
    guard
      let jsonData = suggestionData,
      let json = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? NSArray,
      json.count > 2,
      let availableOptions = json[1] as? [NSArray]
      else { return [:] }
    let suggestions = availableOptions.compactMap { $0[0] as? String }
    return ["rawElements": suggestions]
  }
}

struct GoogleSearch: Google {
  let name: String = "Google"
  let contentTemplate: String = "Search %@ on google"
  let template: String = "https://google.%@/search?q=%@"
  static let keyword: String = "google"
}

struct GoogleImageSearch: Google {
  let name: String = "Google Images"
  let contentTemplate: String = "Search %@ on google image"
  let template: String = "https://google.%@/search?q=%@&tbm=isch"
  static let keyword: String = "image"
}

struct YoutubeSearch: Google {
  let suggestionTemplate: String = "https://clients1.google.com/complete/search?client=safari&q=%@"
  let name: String = "Youtube"
  let contentTemplate: String = "Find %@ on Youtube"
  let template: String = "https://www.youtube.com/results?search_query=%@"
  static let keyword: String = "youtube"
  let icon: NSImage = #imageLiteral(resourceName: "youtube")
}
