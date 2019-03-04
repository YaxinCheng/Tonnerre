//
//  AppFetcher.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-03-04.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Cocoa

enum AppFetcher {
  static func fetchURL(bundleID: String) -> URL? {
    return (LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?
      .takeRetainedValue() as? [URL])?.first
  }
  
  static func fetchIcon(bundleID: String, size: NSSize = NSSize(width: 40, height: 40)) -> NSImage? {
    guard let appURL = (LSCopyApplicationURLsForBundleIdentifier(bundleID as CFString, nil)?
      .takeRetainedValue() as? [URL])?.first else { return nil }
    let icon = NSWorkspace.shared.icon(forFile: appURL.path)
    icon.size = size
    return icon
  }
}
