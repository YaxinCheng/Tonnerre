//
//  Browser.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

enum Browser {
  case safari
  case chrome
  
  var appURL: URL? {
    switch self {
    case .safari:
      let safariURL = URL(fileURLWithPath: "/Applications/Safari.app")
      if FileManager.default.fileExists(atPath: safariURL.path) { return safariURL }
      else { return nil }
    case .chrome:
      let fileManager = FileManager.default
      let userDir = fileManager.homeDirectoryForCurrentUser
      let possibleURL = [URL(fileURLWithPath: "/Applications/Google Chrome.app"), userDir.appendingPathComponent("Applications/Google Chrome.app")]
      for url in possibleURL where fileManager.fileExists(atPath: url.path) {
        return url
      }
      return nil
    }
  }
  
  var icon: NSImage? {
    guard let url = appURL else { return nil }
    switch self {
    case .safari:
      return .safari
    case .chrome:
      return NSImage(contentsOf: url.appendingPathComponent("Contents/Resources/app.icns"))
    }
  }
  
  var bookMarksFile: URL? {
    guard appURL != nil else { return nil }
    switch self {
    case .safari:
      let homeDir = FileManager.default.homeDirectoryForCurrentUser
      return homeDir.appendingPathComponent("/Library/Safari/Bookmarks.plist")
    case .chrome:
      let appSupDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
      return appSupDir?.appendingPathComponent("Google/Chrome/Default/Bookmarks")
    }
  }
  
  var name: String {
    guard appURL != nil else { return "Not Found" }
    switch self {
    case .safari: return "Safari"
    case .chrome: return "Google Chrome"
    }
  }
}
