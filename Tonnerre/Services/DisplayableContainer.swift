//
//  DisplayableContainer.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct DisplayableContainer<T>: Displayable {
  let name: String
  let content: String
  let icon: NSImage
  let innerItem: T?
  
  init(name: String, content: String, icon: NSImage, innerItem: T? = nil) {
    self.name = name
    self.content = content
    self.icon = icon
    self.icon.size = NSSize(width: 64, height: 64)
    self.innerItem = innerItem
  }
}

protocol AsyncedProtocol {
  var asyncedViewSetup: ((ServiceCell)->Void)? { get }
}

struct AsyncedDisplayableContainer<T>: Displayable, AsyncedProtocol {
  let name: String
  let content: String
  let icon: NSImage
  let innerItem: T?
  let asyncedViewSetup: ((ServiceCell)->Void)?
  
  init(name: String, content: String, icon: NSImage, innerItem: T? = nil, viewSetup: ((ServiceCell)->Void)? = nil) {
    self.name = name
    self.content = content
    self.icon = icon
    self.icon.size = NSSize(width: 64, height: 64)
    self.innerItem = innerItem
    self.asyncedViewSetup = viewSetup
  }
}
