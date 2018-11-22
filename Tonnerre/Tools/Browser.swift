//
//  Browser.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

/**
Common browsers on mac, with possible URL paths and bookmarks URLs and icons
*/
enum Browser {
  /**
  Safari browser
  */
  case safari
  /**
  Google Chrome browser
  */
  case chrome
  /**
  Default browser of the system
  */
  case `default`

  /**
  The URL locates the browser application
  - Note: the appURL can be nil when the browser is not installed in the system
  */
  var appURL: URL? {
    let bundleID: CFString
    switch self {
    case .safari:
      bundleID = "com.apple.safari" as CFString
    case .chrome:
      bundleID = "com.google.chrome" as CFString
    case .default:
      return NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://google.ca")!)
    }
    return (LSCopyApplicationURLsForBundleIdentifier(bundleID, nil)?
      .takeRetainedValue() as? [URL])?.first
  }
  
  /**
  icon image for this browser
  */
  var icon: NSImage? {
    guard let url = appURL else { return nil }
    switch self {
    case .safari:
      return .safari
    case .chrome:
      return NSImage(contentsOf: url.appendingPathComponent("Contents/Resources/app.icns"))
    case .default:
      return NSWorkspace.shared.icon(forFile: url.path)
    }
  }
  
  /**
  the URL where the bookmarks file is stored
  */
  var bookMarksFile: URL? {
    guard appURL != nil else { return nil }
    switch self {
    case .safari:
      let homeDir = FileManager.default.homeDirectoryForCurrentUser
      return homeDir.appendingPathComponent("/Library/Safari/Bookmarks.plist")
    case .chrome:
      let appSupDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      return appSupDir?.appendingPathComponent("Google/Chrome/Default/Bookmarks")
    case .default:
      guard let url = appURL else { return nil }
      switch url.deletingPathExtension().lastPathComponent.lowercased() {
      case "Safari": return Browser.safari.bookMarksFile
      case "Chrome": return Browser.chrome.bookMarksFile
      default: return nil
      }
    }
  }
  
  /**
  The browser name
  */
  var name: String {
    guard let url = appURL else { return "Not Found" }
    switch self {
    case .safari: return "Safari"
    case .chrome: return "Google Chrome"
    case .default: return url.deletingPathExtension().lastPathComponent
    }
  }
}
