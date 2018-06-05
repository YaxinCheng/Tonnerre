//
//  WebRequest.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class WebRequest: Displayable {
  let name: String
  let content: String
  let icon: NSImage
  let innerURL: URL
  
  init(name: String, content: String, url: URL, icon: NSImage = #imageLiteral(resourceName: "safari")) {
    self.name = name.capitalized
    self.content = content
    self.innerURL = url
    self.icon = icon
  }
  
  
}
