//
//  LaunchRequest.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct LaunchRequest: Displayable {
  private static let aliasDict: [String: String] = {
    let aliasFile = Bundle.main.path(forResource: "alias", ofType: "plist")!
    return NSDictionary(contentsOfFile: aliasFile) as! [String: String]
  }()
  
  var name: String {
    if innerItem.pathExtension == "prefPane" {
      return LaunchRequest.aliasDict[innerItem.lastPathComponent] ?? innerItem.name
    } else {
      return innerItem.name
    }
  }
  var icon: NSImage {
    return innerItem.icon
  }
  var content: String {
    return innerItem.content
  }
  let innerItem: URL
}
