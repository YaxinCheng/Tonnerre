//
//  Browser.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

/// Common browsers on mac, with possible URL paths and bookmarks URLs and icons
struct Browser: Hashable {
  private static let bundleIds: [String] = {
    let content: Result<[String:String], Error> = PropertyListSerialization.read(fileName: "browsers")
    switch content {
    case .success(let browsersList): return Array(browsersList.values)
    case .failure(let error):
      Logger.error(file: "\(Browser.self)", "Browser BundleIds Reading Error: %{PUBLIC}@", error.localizedDescription)
      return []
    }
  }()
  
  /// Installed identifiable browsers
  private(set) static var installed: Set<Browser> = {
    let browsers = Browser.bundleIds.compactMap { Browser(bundleId: $0) }
    return Set(browsers)
  }()
  
  /// Default browser on this mac
  static var `default`: Browser? {
    guard
      let defaultBrowserURL = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://google.ca")!),
      let defaultBrowser = Browser(url: defaultBrowserURL)
    else { return nil }
    installed.insert(defaultBrowser)
    return defaultBrowser
  }
  
  /// Safari browser
  static var safari: Browser? {
    return Browser(bundleId: "com.apple.safari")
  }
  
  /// Chrome browser
  static var chrome: Browser? {
    return Browser(bundleId: "com.google.chrome")
  }
  
  let name: String
  let bundleId: String
  let appURL: URL
  var icon: NSImage {
    return NSWorkspace.shared.icon(forFile: appURL.path)
  }
  
  /// The file stores the bookmarks of this browser
  var bookMarksFile: URL? {
    switch bundleId {
    case "com.apple.safari":
      let homeDir = FileManager.default.homeDirectoryForCurrentUser
      return homeDir.appendingPathComponent("/Library/Safari/Bookmarks.plist")
    case "com.google.chrome":
      let appSupDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      return appSupDir?.appendingPathComponent("Google/Chrome/Default/Bookmarks")
    default: return nil
    }
  }

  private init?(bundleId: String) {
    guard
      let browserURL = AppFetcher.fetchURL(bundleID: bundleId)
    else { return nil }
    self.name = browserURL.deletingPathExtension().lastPathComponent
    self.bundleId = bundleId
    self.appURL = browserURL
  }
  
  private init?(url: URL) {
    guard
      let bundleId = Bundle(url: url)?.bundleIdentifier?.lowercased()
    else { return nil }
    self.bundleId = bundleId
    self.name = url.deletingPathExtension().lastPathComponent
    self.appURL = url
  }
  
  var hash: Int {
    return bundleId.hash
  }
}
