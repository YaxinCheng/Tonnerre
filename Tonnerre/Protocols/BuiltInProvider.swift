//
//  TonnerreService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol BuiltInProvider: ServiceProvider {
}
extension BuiltInProvider {
  var alterContent: String? { return nil }
  var alterIcon: NSImage? { return nil }
  var argUpperBound: Int { return argLowerBound }
  var id: String { return "\(Self.self)" }
  /**
   A bool value specifies if the service is disabled. Disabled services cannot be called
  */

  var placeholder: String {
    return keyword
  }
}

protocol TonnerreInstantService {}
