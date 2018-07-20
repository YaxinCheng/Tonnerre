//
//  DynamicServiceBound.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct DynamicServiceBound: Displayable {
  var icon: NSImage {
    return result.icon
  }
  
  var placeholder: String {
    return result.placeholder
  }
  
  var name: String {
    return result.name
  }
  
  var content: String {
    return result.content
  }
  
  let service: DisplayableContainer<String>
  let result: Displayable
}
