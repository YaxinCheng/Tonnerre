//
//  TrashEmptyService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct TrashEmptyService: TonnerreService {
  let name: String = "Empty Trash"
  let keyword: String = "empty"
  let content: String = "Empty your trash instantly"
  let arguments: [String] = []
  let hasPreview: Bool = false
  let icon: NSImage = #imageLiteral(resourceName: "trash")
  
  func prepare(input: [String]) -> [Displayable] {
    guard input.count == 0 else { return [] }
    return [self]
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    let cleanScript = """
    tell application "Finder"
    if length of (items in the trash as string) is 0 then return
      empty trash
    end tell
    """
    guard let appScript = NSAppleScript(source: cleanScript) else { return }
    appScript.executeAndReturnError(nil)
  }
}
