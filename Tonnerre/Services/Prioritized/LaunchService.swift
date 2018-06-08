//
//  LaunchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct LaunchService: TonnerreService {
  let keyword: String = ""
  let arguments: [String] = ["query"]
  let hasPreview: Bool = false
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  
  func prepare(input: [String]) -> [Displayable] {
    let indexStorage = IndexStorage()
    let index = indexStorage[.defaultMode]
    let query = input.joined(separator: " ")
    guard !query.starts(with: "http") else { return [] }
    return index.search(query: query + "*", limit: 9 * 9, options: .defaultOption).map(LaunchRequest.init)
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let appURL = (source as? LaunchRequest)?.innerItem else { return }
    let workspace = NSWorkspace.shared
    workspace.open(appURL)
  }
}
