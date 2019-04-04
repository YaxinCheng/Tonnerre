//
//  KeywordResource.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-04-04.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct KeywordResource: EnvResource {
  
  private let idToKeywordList: [String : String]
  private let _KEYWORD_LIST_NAME = "builtinKeywords"
  
  init() {
    guard
      let fileURL = Bundle.main.url(forResource: _KEYWORD_LIST_NAME, withExtension: "plist"),
      let fileData = try? Data(contentsOf: fileURL),
      let keywordList = try? PropertyListSerialization.propertyList(from: fileData, format: nil) as? [String : String]
    else {
      idToKeywordList = [:]
      return
    }
    idToKeywordList = keywordList
  }
  
  func export(to env: Environment) {
    let keywordKeyTemplate = "%@.keyword"
    for (id, keyword) in idToKeywordList {
      UserDefaults.shared.set(keyword, forKey: String(format: keywordKeyTemplate, id))
    }
  }
}
