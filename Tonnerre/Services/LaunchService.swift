//
//  LaunchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct LaunchService: TonnerreService {
  
  let name: String = ""
  let keyword: String = ""
  let arguments: [String] = []
  let hasPreview: Bool = false
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  
  func process(input: [String]) -> [Displayable] {
    let indexStorage = IndexStorage()
    let index = indexStorage[.defaultMode]
    return index.search(query: input.joined(separator: " ") + "*", limit: 9 * 9, options: .defaultOption)
  }
}
