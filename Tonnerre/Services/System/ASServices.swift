//
//  LockService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-04.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct LockService: AppleScriptServiceProtocol {
  static let keyword: String = "lock"
  var icon: NSImage {
    return #imageLiteral(resourceName: "lock").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  let name: String = "Lock Screen"
  let content: String = "Lock your Mac"
  let script: String = "tell application \"Finder\" to sleep"
}

struct TrashEmptyService: AppleScriptServiceProtocol {// Clean transh bin
  let name: String = "Empty Trash"
  static let keyword: String = "empty"
  let content: String = "Empty your trash instantly"
  let icon: NSImage = .trash
  let script: String = """
    tell application "Finder"
    if length of (items in the trash as string) is 0 then return
      empty trash
    end tell
    """
}

struct ScreenSaverService: AppleScriptServiceProtocol {
  static let keyword: String = "lock"
  let icon: NSImage = .screenLock
  let name: String = "Screen Saver"
  let content: String = "Lock your Mac & Launch Screen Saver"
  let script: String = """
  tell application "System Events"
  start current screen saver
  end tell
  """
}
