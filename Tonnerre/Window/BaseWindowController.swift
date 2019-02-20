//
//  BaseWindowController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class BaseWindowController: NSWindowController, NSWindowDelegate {
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    #if RELEASE
    let userDefault = UserDefaults.standard
    if
      let x = userDefault.value(forKey: .designatedX) as? CGFloat,
      let y = userDefault.value(forKey: .designatedY) as? CGFloat {
      window?.setFrameOrigin(NSPoint(x: max(x, 0), y: max(y, 0)))
    } else {
      guard
        let screenSize = NSScreen.main,
        let myWindow = window
      else { return }
      let x = screenSize.width / 2 - myWindow.frame.width / 2
      let y = screenSize.height * 5 / 6
      userDefault.set(screenSize.width, forKey: "screenWidth")
      userDefault.set(screenSize.height, forKey: "screenHeight")
      myWindow.setFrameOrigin(NSPoint(x: x, y: y))
    }
    #endif
  }
  
  func windowDidResignKey(_ notification: Notification) {
    (window as? BaseWindow)?.isHidden = true
  }
  
  func windowDidMove(_ notification: Notification) {
    let userDefault = UserDefaults.standard
    let (x, y) = (window!.frame.origin.x, window!.frame.origin.y)
    #if RELEASE
    userDefault.set(x, forKey: .designatedX)
    userDefault.set(y, forKey: .designatedY)
    #endif
  }
}
