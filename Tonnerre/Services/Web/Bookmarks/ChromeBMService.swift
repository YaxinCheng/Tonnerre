//
//  ChromeBMService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ChromeBMService: BookMarkService {
  let name: String = "Chrome BookMarks"
  let content: String = "Quick launch Chrome Bookmarks"
  let keyword: String = "chrome"
  let defered: Bool = true
  static let browser: Browser? = .chrome
  
  init() {
    let disableManager = DisableManager.shared
    let isDisabled = disableManager.isDisabled(provider: self)
    if ChromeBMService.browser == nil || isDisabled {
      disableManager.disable(providerID: id)
    } else {
      disableManager.enable(providerID: id)
    }
  }
  
  func parseFile() throws -> [BookMarkService.BookMark] {
    guard let bmFile = type(of: self).browser?.bookMarksFile else { return [] }
    let jsonData = try Data(contentsOf: bmFile)
    guard let jsonObject = JSON(data: jsonData) else { return [] }
    let bookmarBar = (jsonObject["roots", "bookmark_bar", "children"] as? [Dictionary<String, Any>]) ?? []
    let other = (jsonObject["roots", "other", "children"] as? [Dictionary<String, Any>]) ?? []
    return bookmarBar.compactMap(parse) + other.compactMap(parse)
  }
  
  private func parse(rawContent: Dictionary<String, Any>) -> BookMarkService.BookMark? {
    guard
      let name = rawContent["name"] as? String,
      let URLString = rawContent["url"] as? String,
      let url = URL(string: URLString)
    else { return nil }
    return (name, url)
  }
}
