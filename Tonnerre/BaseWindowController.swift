//
//  BaseWindowController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class BaseWindowController: NSWindowController, NSWindowDelegate {
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    #if RELEASE
    let userDefault = UserDefaults.standard
    if
      let x = userDefault.value(forKey: StoredKeys.designatedX.rawValue) as? Int,
      let y = userDefault.value(forKey: StoredKeys.designatedY.rawValue) as? Int {
      window?.setFrameOrigin(NSPoint(x: max(x, 0), y: max(y, 0)))
    } else {
      guard let screenSize = NSScreen.main?.frame.size, let myWindow = window else { return }
      let x = screenSize.width / 2 - myWindow.frame.width / 2
      let y = screenSize.height * 5 / 6
      myWindow.setFrameOrigin(NSPoint(x: x, y: y))
      userDefault.set(x, forKey: StoredKeys.designatedX.rawValue)
      userDefault.set(y, forKey: StoredKeys.designatedY.rawValue)
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
    userDefault.set(x, forKey: StoredKeys.designatedX.rawValue)
    userDefault.set(y, forKey: StoredKeys.designatedY.rawValue)
    #endif
  }
}
