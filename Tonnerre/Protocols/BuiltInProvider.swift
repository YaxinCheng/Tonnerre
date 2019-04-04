//
//  TonnerreService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol BuiltInProvider: ServiceProvider {
  /**
   Constructor.
   - Note: no parameter should be given for TonnerreService constructors
   */
  init()
}
extension BuiltInProvider {
  var alterContent: String? { return nil }
  var keyword: String {
    let key = String(format: "%@.keyword", id)
    return UserDefaults.shared.string(forKey: key) ?? ""
  }
  var alterIcon: NSImage? { return nil }
  var argUpperBound: Int { return argLowerBound }
  var id: String { return "Tonnerre.Provider.BuiltIn.\(Self.self)" }
  var placeholder: String {
    return keyword
  }
}
