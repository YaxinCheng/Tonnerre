//
//  BaseWindow.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import HotKey

final class BaseWindow: NSPanel {
  override var canBecomeKey: Bool {
    return true
  }
  
  var isHidden: Bool = false {
    willSet {
      #if RELEASE
      if !isHidden && newValue == true {
        DispatchQueue.main.async { [unowned self] in
          self.orderOut(self)
          let notification = Notification(name: .windowIsHiding)
          NotificationCenter.default.post(notification)
        }
      } else if isHidden && newValue == false {
        DispatchQueue.main.async { [unowned self] in
          self.makeKeyAndOrderFront(self)
          self.orderFrontRegardless()
        }
      }
      TonnerreHelper.launch()
      #endif
    }
  }
  
  let hotkey: HotKey
  
  override func setFrameOrigin(_ point: NSPoint) {
    super.setFrameOrigin(point)
    UserDefaults.standard.set(point.x, forKey: .designatedX)
    UserDefaults.standard.set(point.y, forKey: .designatedY)
  }
  
  override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
    hotkey = HotKey(key: .space, modifiers: [.option])
    super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    hotkey.keyDownHandler = { [weak self] in
      self?.isHidden = !(self?.isHidden ?? true)
    }
    
    isMovableByWindowBackground = true
    isMovable = true
    level = .screenSaver
    backgroundColor = .clear
    collectionBehavior = [.ignoresCycle, .canJoinAllSpaces]
  }
}
