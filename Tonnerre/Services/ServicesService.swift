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
  let content: String = ""
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  
  func prepare(input: [String]) -> [Displayable] {
    return TonnerreInterpreter.loader.autoComplete(key: input.joined(separator: " "), type: .normal, includeExtra: false)
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let service = source as? TonnerreService else { return }
    type(of: service).isDisabled = !(type(of: service).isDisabled)
  }
}
