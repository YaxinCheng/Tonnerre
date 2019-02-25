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
    return fetchApplicationIcon(by: "com.apple.safari" as CFString) ?? #imageLiteral(resourceName: "notFound")
  }

  static var finder: NSImage {
    return fetchApplicationIcon(by: "com.apple.finder" as CFString) ?? #imageLiteral(resourceName: "notFound")
  }
  
  static var dictionary: NSImage {
    return fetchApplicationIcon(by: "com.apple.dictionary" as CFString) ?? #imageLiteral(resourceName: "notFound")
  }
  
  static var calculator: NSImage {
    return fetchApplicationIcon(by: "com.apple.calculator" as CFString) ?? #imageLiteral(resourceName: "notFound")
  }
  
  fileprivate static func fetchApplicationIcon(by bundleID: CFString) -> NSImage? {
    guard let appURL = (LSCopyApplicationURLsForBundleIdentifier(bundleID, nil)?
      .takeRetainedValue() as? [URL])?.first else { return nil }
    let icon = NSWorkspace.shared.icon(forFile: appURL.path)
    icon.size = NSSize(width: 40, height: 40)
    return icon
  }
}
