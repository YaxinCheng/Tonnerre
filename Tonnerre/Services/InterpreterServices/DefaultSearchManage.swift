//
//  DefaultSearchManage.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 This enum defines which service to use when there is not matched services from the input
 Generally, google/bing/duckDuckGo like web search services will be prefered
*/
enum DefaultSearchOption: String {
  case google
  case bing
  case duckDuckGo
  
  init?(rawValue: String) {
    switch rawValue.lowercased() {
    case "google": self = .google
    case "bing": self = .bing
    case "duck", "duckduckgo": self = .duckDuckGo
    default: return nil
    }
  }
  
  var associatedService: WebService.Type {
    switch self {
    case .google: return GoogleSearch.self
    case .bing: return BingSearch.self
    case .duckDuckGo: return DuckDuckGoSearch.self
    }
  }
  
  static var defaultSearch: DefaultSearchOption {
    get {
      let userDefault = UserDefaults.standard
      let value = userDefault.string(forKey: StoredKeys.defaultSearch.rawValue) ?? "google"
      return DefaultSearchOption(rawValue: value)!
    } set {
      let userDefault = UserDefaults.standard
      userDefault.setValue(newValue.rawValue, forKeyPath: StoredKeys.defaultSearch.rawValue)
    }
  }
}
