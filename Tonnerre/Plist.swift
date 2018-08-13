//
//  Plist.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Plist {
  let fileURL: URL
  
  func read() -> Dictionary<String, Any>? {
    return NSDictionary(contentsOf: fileURL) as? Dictionary<String, Any>
  }
  
  func write(plist: Any) {
    guard
      let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
    else { return }
    do {
      try data.write(to: fileURL)
    } catch {
      #if DEBUG
      print(error)
      #endif
    }
  }
}
