//
//  DisplayContainer.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct DisplayContainer<T>: DisplayItem {
  let name: String
  var content: String
  var icon: NSImage
  var innerItem: T?
  let _placeholder: String?
  var placeholder: String {
    return _placeholder ?? ((innerItem as? DisplayItem)?.placeholder ?? name)
  }
  var config: ContainerConfig? = nil
  let alterContent: String?
  let alterIcon: NSImage?
  
  init(name: String, content: String, icon: NSImage, alterContent: String? = nil, alterIcon: NSImage? = nil, innerItem: T? = nil, placeholder: String? = nil, config: ContainerConfig? = nil) {
    self.name = name
    self.content = content
    self.icon = icon
    self.icon.size = NSSize(width: 40, height: 40)
    self.innerItem = innerItem
    self._placeholder = placeholder
    self.config = config
    self.alterContent = alterContent
    self.alterIcon = alterIcon
  }
}
