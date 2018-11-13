//
//  Placeholder.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-12.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct Placeholder: DisplayProtocol {
  let icon: NSImage
  let placeholder: String
  let name: String
  let content: String
  
  init(icon: NSImage, placeholder: String, name: String, content: String) {
    self.icon = icon
    self.placeholder = placeholder
    self.name = name
    self.content = content
  }
  
  init(fromProvider provider: ServiceProvider, query: [String]) {
    self.icon = provider.icon
    self.placeholder = provider.keyword
    self.name = provider.name.filled(arguments: query)
    self.content = provider.content.filled(arguments: query)
  }
}
