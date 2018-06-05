//
//  MapService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct AppleMapService: WebService {
  let template: String = "https://maps.apple.com/?q=%@"
  let suggestionTemplate: String = ""
  let loadSuggestion: Bool = false
  func processJSON(data: Data?) -> [String : Any] {
    return [:]
  }
  let keyword: String = "map"
  let arguments: [String] = ["location"]
  let hasPreview: Bool = false
  let name: String = "Apple Maps"
  let contentTemplate: String = "Search %@ on Apple Maps"
  var icon: NSImage {
    let workspace = NSWorkspace.shared
    let icon = workspace.icon(forFile: "/Applications/Maps.app")
    icon.size = NSSize(width: 64, height: 64)
    return icon
  }
}
