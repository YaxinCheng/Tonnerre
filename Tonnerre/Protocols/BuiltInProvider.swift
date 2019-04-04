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
  /// Default keyword associated with this provider
  ///
  /// It is not used generally. It only serves as an insurance
  /// if the data in UserDefaults are corrupted
  var defaultKeyword: String { get }
}
extension BuiltInProvider {
  var alterContent: String? { return nil }
  var keyword: String {
    return BuiltInProviderMap.extractKeyword(from: Self.self)
  }
  var alterIcon: NSImage? { return nil }
  var argUpperBound: Int { return argLowerBound }
  var id: String { return BuiltInProviderMap.extractID(from: Self.self) }
  var placeholder: String {
    return keyword
  }
}
