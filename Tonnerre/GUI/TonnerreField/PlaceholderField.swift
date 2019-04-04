//
//  PlaceholderField.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class PlaceholderField: NSTextField {
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
  
  override func mouseUp(with event: NSEvent) {
    guard event.clickCount == 2 else { return }
    guard
      let designedFrame = window?.frame,
      let mainScreen = NSScreen.main
    else { return }
    let x = mainScreen.frame.width/2 - designedFrame.width/2
    let y = mainScreen.frame.height * 5 / 6 - designedFrame.height
    window?.setFrameOrigin(NSPoint(x: x, y: y))
  }
}
