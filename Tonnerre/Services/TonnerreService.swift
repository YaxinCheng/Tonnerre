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
  var arguments: [String] { get }
  var hasPreview: Bool { get }
//  var enabled: Bool { get set }
  func prepare(input: [String]) -> [Displayable]
  func serve(source: Displayable, withCmd: Bool)
  init()
}
