//
//  DisplayContainer.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct DisplayContainer<T>: DisplayProtocol {
  let name: String
  var content: String
  var icon: NSImage
  var innerItem: T?
  let _placeholder: String?
  var placeholder: String {
    return _placeholder ?? ((innerItem as? DisplayProtocol)?.placeholder ?? name)
  }
  var extraContent: ContainerConfig? = nil
  let alterContent: String?
  let alterIcon: NSImage?
  
  init(name: String, content: String, icon: NSImage, alterContent: String? = nil, alterIcon: NSImage? = nil, innerItem: T? = nil, placeholder: String? = nil, extraContent: ContainerConfig? = nil) {
    self.name = name
    self.content = content
    self.icon = icon
    self.icon.size = NSSize(width: 64, height: 64)
    self.innerItem = innerItem
    self._placeholder = placeholder
    self.extraContent = extraContent
    self.alterContent = alterContent
    self.alterIcon = alterIcon
  }
}
