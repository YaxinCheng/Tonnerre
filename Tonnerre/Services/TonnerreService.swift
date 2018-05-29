//
//  TonnerreService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

protocol TonnerreService {
  associatedtype resultType
  var keywords: [String] { get }
  var arguments: [String] { get }
  var icon: NSImage { get }
  var hasPreview: Bool { get }
  func preview(loc: resultType)
  func process(input: [String]) -> [resultType]
}

extension TonnerreService {
  var serviceName: String {
    return "\(Self.self)"
  }
}

protocol FileSearchService: TonnerreService where resultType == URL {
  static var core: CoreSearch { get }
}

extension FileSearchService {
  
  static var core: CoreSearch {
    return CoreSearch()
  }
  var icon: NSImage { return NSImage(named: .advanced)! }
  var hasPreview: Bool { return false }
  func preview(loc: URL) { }
}
