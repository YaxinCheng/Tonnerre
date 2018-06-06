//
//  SystemRequest.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct SystemRequest<T>: Displayable {
  let name: String
  let content: String
  let icon: NSImage
  let innerItem: T

  init(name: String, content: String, icon: NSImage, innerItem: T) {
    self.name = name
    self.content = content
    self.icon = icon
    self.icon.size = NSSize(width: 64, height: 64)
    self.innerItem = innerItem
  }
}
