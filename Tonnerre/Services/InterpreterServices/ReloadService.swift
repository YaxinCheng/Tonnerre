//
//  ReloadService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-18.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ReloadService: TonnerreService {
  static let keyword: String = "@reload"
  let argLowerBound: Int = 0
  let name: String = "Reload Service"
  let content: String = "Reload the extended service from files again..."
  var icon: NSImage {
    return #imageLiteral(resourceName: "tonnerre").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard input.count == 0 else { return [] }
    return [self]
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    TonnerreInterpreter.loader.reload()
  }

}
