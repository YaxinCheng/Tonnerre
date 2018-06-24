//
//  DefaultService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-23.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct DefaultService: TonnerreInterpreterService {
  static let keyword: String = "@default"
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  
  func prepare(input: [String]) -> [Displayable] {
    let query = input.joined(separator: " ")
    return (TonnerreInterpreter.loader.autoComplete(key: query, type: .normal, includeExtra: false)
      + TonnerreInterpreter.loader.autoComplete(key: query, type: .system, includeExtra: false))
      .filter { !(type(of: $0).isDisabled || ($0 as? TonnerreExtendService)?.isDisabled ?? false) }
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    
  }
}
