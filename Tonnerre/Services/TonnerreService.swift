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
  var keyword: String { get }
  var argLowerBound: Int { get }
  var argUpperBound: Int { get }
  var hasPreview: Bool { get }
  var alterContent: String? { get }
  var alterIcon: NSImage? { get }
  func prepare(input: [String]) -> [Displayable]
  func serve(source: Displayable, withCmd: Bool)
  
  init()
}
extension TonnerreService {
  var alterContent: String? { return nil }
  var alterIcon: NSImage? { return nil }
  var argUpperBound: Int { return argLowerBound }
}
