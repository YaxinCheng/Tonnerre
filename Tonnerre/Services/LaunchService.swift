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
  
  func prepare(input: [String]) -> [Displayable] {
    let indexStorage = IndexStorage()
    let index = indexStorage[.defaultMode]
    return index.search(query: input.joined(separator: " ") + "*", limit: 9 * 9, options: .defaultOption)
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let appURL = source as? URL else { return }
    let workspace = NSWorkspace.shared
    workspace.open(appURL)
  }
}
