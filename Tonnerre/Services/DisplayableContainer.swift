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
  let _placeholder: String
  var placeholder: String {
    return _placeholder.isEmpty ? (innerItem as? Displayable)?.placeholder ?? "" : _placeholder
  }
  var extraContent: Any? = nil
  
  init(name: String, content: String, icon: NSImage, innerItem: T? = nil, placeholder: String = "", extraContent: Any? = nil) {
    self.name = name
    self.content = content
    self.icon = icon
    self.icon.size = NSSize(width: 64, height: 64)
    self.innerItem = innerItem
    self._placeholder = placeholder
    self.extraContent = extraContent
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
  let _placeholder: String
  var placeholder: String {
    return _placeholder.isEmpty ? (innerItem as? Displayable)?.placeholder ?? "" : _placeholder
  }
  
  init(name: String, content: String, icon: NSImage, innerItem: T? = nil, placeholder: String = "", viewSetup: ((ServiceCell)->Void)? = nil) {
    self.name = name
    self.content = content
    self.icon = icon
    self.icon.size = NSSize(width: 64, height: 64)
    self.innerItem = innerItem
    self._placeholder = placeholder
    self.asyncedViewSetup = viewSetup
  }
}
