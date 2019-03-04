//
//  NSImage+Tint.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

extension NSImage {
  static var safari: NSImage {
    return AppFetcher.fetchIcon(bundleID: "com.apple.safari") ?? #imageLiteral(resourceName: "notFound")
  }

  static var finder: NSImage {
    return AppFetcher.fetchIcon(bundleID: "com.apple.finder") ?? #imageLiteral(resourceName: "notFound")
  }
  
  static var dictionary: NSImage {
    return AppFetcher.fetchIcon(bundleID: "com.apple.dictionary") ?? #imageLiteral(resourceName: "notFound")
  }
  
  static var calculator: NSImage {
    return AppFetcher.fetchIcon(bundleID: "com.apple.calculator") ?? #imageLiteral(resourceName: "notFound")
  }
}
