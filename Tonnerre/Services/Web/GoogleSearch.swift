//
//  GoogleSearch.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

fileprivate protocol Google: WebService {
}

extension Google {
  var icon: NSImage { return #imageLiteral(resourceName: "google") }
  var argLowerBound: Int { return 1 }
  var argUpperBound: Int { return .max }
  
  func parse(suggestionData: Data?) -> [String] {
    guard
      let jsonData = suggestionData,
      let json = JSON(data: jsonData),
      json.count > 2,
      let availableOptions: [[Any]] = json[1]
    else { return [] }
    return availableOptions.compactMap { $0[0] as? String }
  }
}

struct GoogleSearch: Google {
  let name: String = "Google"
  let contentTemplate: String = "Search \"%@\" on Google"
  let defaultKeyword: String = "google"
}

struct GoogleImageSearch: Google {
  let name: String = "Google Images"
  let contentTemplate: String = "Search \"%@\" on Google Image"
  let defaultKeyword: String = "image"
}

struct YoutubeSearch: Google {
  let name: String = "YouTube"
  let contentTemplate: String = "Find \"%@\" on Youtube"
  let defaultKeyword: String = "youtube"
  let icon: NSImage = #imageLiteral(resourceName: "youtube")
}
