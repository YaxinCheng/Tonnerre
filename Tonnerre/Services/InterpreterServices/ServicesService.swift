//
//  ServicesServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-15.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ServicesService: TonnerreInterpreterService {
  static let keyword: String = "@services"
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  let itemIdentifier: NSUserInterfaceItemIdentifier = .OnOffCell
  
  func prepare(input: [String]) -> [Displayable] {
    let query = input.joined(separator: " ")
    return TonnerreInterpreter.loader.autoComplete(key: query, type: .normal, includeExtra: false)
    + TonnerreInterpreter.loader.autoComplete(key: query, type: .system, includeExtra: false)
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    if let service = source as? TonnerreExtendService {
      service.isDisabled = !service.isDisabled
    } else if let service = source as? TonnerreService {
      type(of: service).isDisabled = !(type(of: service).isDisabled)
    }
  }
}
