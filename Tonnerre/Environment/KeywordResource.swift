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
  private let _KEYWORD_KEY_TEMPLATE = "%@.keyword"
  
  init() {
    let content: Result<[String: String], Error> = PropertyListSerialization.read(fileName: _KEYWORD_LIST_NAME)
    switch content {
    case .success(let keywordList):
      idToKeywordList = keywordList
    case .failure(_):
      idToKeywordList = [:]
    }
  }
  
  func export(to env: Environment) {
    for (id, keyword) in idToKeywordList {
      UserDefaults.shared.set(keyword, forKey: String(format: _KEYWORD_KEY_TEMPLATE, id))
    }
  }
}
