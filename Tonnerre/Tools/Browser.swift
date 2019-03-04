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
enum Browser: String, CaseIterable {
  case safari
  case chrome = "Google Chrome"
  case fireFox
  case chromium
  case opera
  case qqBrowser
  
  /// Fetch the default browser. If not supported, then use safari
  static var `default`: Browser {
    guard
      let defaultBrowserURL = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://google.ca")!)
    else { return .safari }
    let name = defaultBrowserURL.deletingPathExtension().lastPathComponent
    return Browser(rawValue: name) ?? .safari
  }
  
  init?(rawValue: String) {
    switch rawValue.lowercased() {
    case "safari": self = .safari
    case "chrome", "google chrome": self = .chrome
    case "firefox": self = .fireFox
    case "opera": self = .opera
    case "qqbrowser": self = .qqBrowser
    default: return nil
    }
  }
  
  private static let bundleIds: [String : String] = {
    guard
      let bundleFile = Bundle.main.url(forResource: "browsers", withExtension: "plist"),
      let fileData = try? Data(contentsOf: bundleFile),
      let plistContent = try? PropertyListSerialization.propertyList(from: fileData, format: nil)
    else { return [:] }
    return (plistContent as? [String : String]) ?? [:]
  }()

  /// The URL locates the browser application
  /// - Note: the appURL can be nil when the browser is not installed in the system
  var appURL: URL? {
    guard let bundleId = Browser.bundleIds[rawValue.capitalized] else { return nil }
    return AppFetcher.fetchURL(bundleID: bundleId)
  }
  
  /// Indicator for if the browser is installed
  var installed: Bool {
    return appURL != nil
  }
  
  /// icon image for this browser
  var icon: NSImage? {
    guard let bundleId = Browser.bundleIds[rawValue.capitalized] else { return nil }
    return AppFetcher.fetchIcon(bundleID: bundleId)
  }
  
  /// the URL where the bookmarks file is stored
  var bookMarksFile: URL? {
    guard appURL != nil else { return nil }
    switch self {
    case .safari:
      let homeDir = FileManager.default.homeDirectoryForCurrentUser
      return homeDir.appendingPathComponent("/Library/Safari/Bookmarks.plist")
    case .chrome:
      let appSupDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      return appSupDir?.appendingPathComponent("Google/Chrome/Default/Bookmarks")
    default: return nil
    }
  }
  
  /// The browser name
  var name: String {
    return rawValue.capitalized
  }
}
