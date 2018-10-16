//
//  BookmarksService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-18.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 A protocol for loading bookmarks from safari and chrome
*/
protocol BookMarkService: TonnerreService {
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
  var priority: DisplayPriority { return .low }
  var icon: NSImage {
    return type(of: self).browser.icon ?? #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  static var isDisabled: Bool {
    get {
      guard browser.appURL != nil else { return true }
      let userDeafult = UserDefaults.shared
      return userDeafult.bool(forKey: settingKey)
    } set {
      let userDeafult = UserDefaults.shared
      userDeafult.set(newValue, forKey: settingKey)
    }
  }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    let bookMarks: [BookMark]
    do {
      bookMarks = try parseFile()
    } catch {
      let errorTitle   = "Error loading \(type(of: self).browser.name) bookmarks"
      let errorContent = "Please add `Tonnerre.app` to System Preference - Security & Privacy - Full Disk Access"
      let error = DisplayableContainer<Int>(name: errorTitle, content: errorContent, icon: icon, priority: .low, placeholder: "")
      return [error]
    }
    let regex = try! NSRegularExpression(pattern: ".*?\(input.joined(separator: ".*?")).*?", options: .caseInsensitive)
    let filteredBMs = bookMarks.filter {
      regex.numberOfMatches(in: $0.title, options: .withoutAnchoringBounds, range: NSRange($0.title.startIndex..<$0.title.endIndex, in: $0.title)) >= 1
    }
    return filteredBMs.map { DisplayableContainer(name: $0.title, content: $0.url.absoluteString, icon: icon, priority: priority, innerItem: $0.url, placeholder: $0.title) }
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    if let browserURL = Self.browser.appURL,
    let innerItem = (source as? DisplayableContainer<URL>)?.innerItem {
      do {
        _ = try NSWorkspace.shared.open([innerItem], withApplicationAt: browserURL, options: .default, configuration: [:])
      } catch {
        #if DEBUG
        print("Browser open bookmarks:", error)
        #endif
      }
    } else if source is DisplayableContainer<Int> {
      guard
        let settingPanelURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")
      else { return }
      NSWorkspace.shared.open(settingPanelURL)
    }
  }
}
