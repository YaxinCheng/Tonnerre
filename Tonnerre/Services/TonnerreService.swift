//
//  TonnerreService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

protocol TonnerreService: Displayable {
  static var keyword: String { get }
  var argLowerBound: Int { get }
  var argUpperBound: Int { get }
  func prepare(input: [String]) -> [Displayable]
  func serve(source: Displayable, withCmd: Bool)
  
  init()
}
extension TonnerreService {
  var alterContent: String? { return nil }
  var alterIcon: NSImage? { return nil }
  var argUpperBound: Int { return argLowerBound }
}

protocol TonnerreExtendService: TonnerreService, Codable {
  var keyword: String { get }
}

extension TonnerreExtendService {
  static var keyword: String { return "ExtendedService" }
  init() { fatalError("Load from JSON instead") }
}

protocol TonnerreInterpreterService: TonnerreService {
}
