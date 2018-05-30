//
//  Displayable.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol Displayable {
  var icon: NSImage { get }
  var name: String { get }
  var content: String { get }
}

extension Displayable {
  var name: String {
    return "\(Self.self)"
  }
  
  var content: String {
    return ""
  }
}

extension URL: Displayable {
  var name: String {
    return self.lastPathComponent
  }
  
  var content: String {
    return self.path
  }
  
  var icon: NSImage {
    return isFileURL || isDirectory || isSymlink ? #imageLiteral(resourceName: "Finder") : #imageLiteral(resourceName: "safari")
  }
}
