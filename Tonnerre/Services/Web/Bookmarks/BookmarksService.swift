//
//  BookmarksService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-18.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

/**
 A protocol for loading bookmarks from safari and chrome
*/
protocol BookMarkService: BuiltInProvider {
  /**
   Type of bookmark
  */
  typealias BookMark = (title: String, url: URL)
  /**
   The browser which stores the bookmarks
  */
  static var browser: Browser { get }
  /**
   Read bookmarks data from the browser's file
   
   - returns: an array of bookmarks without grouping
  */
  func parseFile() throws -> [BookMark]
}

extension BookMarkService {
  var argLowerBound: Int { return 1 }
  var argUpperBound: Int { return Int.max }
  var icon: NSImage {
    return type(of: self).browser.icon ?? #imageLiteral(resourceName: "notFound")
  }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    let bookMarks: [BookMark]
    do {
      bookMarks = try parseFile()
    } catch {
      let errorTitle   = "Error loading \(type(of: self).browser.name) bookmarks"
      let errorContent = "Please add `Tonnerre.app` to System Preference - Security & Privacy - Full Disk Access"
      let errorMsg = DisplayContainer<Error>(name: errorTitle, content: errorContent, icon: icon, innerItem: error, placeholder: "")
      return [errorMsg]
    }
    let regex = try! NSRegularExpression(pattern: ".*?\(input.joined(separator: ".*?")).*?", options: .caseInsensitive)
    let filteredBMs = bookMarks.filter {
      regex.numberOfMatches(in: $0.title, options: .withoutAnchoringBounds, range: NSRange($0.title.startIndex..<$0.title.endIndex, in: $0.title)) >= 1
    }
    return filteredBMs.map { DisplayContainer(name: $0.title, content: $0.url.absoluteString, icon: icon, innerItem: $0.url, placeholder: $0.title) }
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    if let browserURL = Self.browser.appURL,
    let innerItem = (service as? DisplayContainer<URL>)?.innerItem {
      do {
        _ = try NSWorkspace.shared.open([innerItem], withApplicationAt: browserURL, options: .default, configuration: [:])
      } catch {
        #if DEBUG
        print("Browser open bookmarks:", error)
        #endif
      }
    } else if service is DisplayContainer<Error> {
      guard
        let settingPanelURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")
      else { return }
      NSWorkspace.shared.open(settingPanelURL)
    }
  }
}
