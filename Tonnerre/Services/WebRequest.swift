//
//  WebRequest.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct WebRequest: Displayable {
  let name: String
  let content: String
  let icon: NSImage
  private let workspace = NSWorkspace.shared
  
  init(name: String, content: String, icon: NSImage = #imageLiteral(resourceName: "safari")) {
    self.name = name.capitalized
    self.content = content
    self.icon = icon
  }
  
  
}
