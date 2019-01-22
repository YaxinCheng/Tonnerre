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
          self.resetWindownLocation()
          self.makeKeyAndOrderFront(self)
          self.orderFrontRegardless()
        }
      }
      launchHelper()
      #endif
    }
  }
  
  /**
   Works in multi-display environment. This function puts the window to the main screen (with a window currently accepting keyboard events) at a similar location like in the previous screen
  */
  private func resetWindownLocation() {
    #if RELEASE
    let mouseLocation = NSEvent.mouseLocation
    let userDefault = UserDefaults.standard
    guard
      let screenWidth = userDefault.value(forKey: "screenWidth") as? CGFloat,
      let screenHeight = userDefault.value(forKey: "screenHeight") as? CGFloat,
      let currScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
    else { return }
    let (currScreenWidth, currScreenHeight) = (currScreen.frame.width, currScreen.frame.height)
    let (x, y) = (frame.origin.x, frame.origin.y)
    let (ratioX, ratioY) = (x / screenWidth * currScreenWidth, y / screenHeight * currScreenHeight)
    setFrameOrigin(NSPoint(x: ratioX, y: ratioY))
    #endif
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
    level = .floating
    backgroundColor = .clear
    collectionBehavior = [.ignoresCycle, .canJoinAllSpaces]
    
    folderChecks()
    setupCache()
    launchHelper()
    setupSettings()
  }
  
  private func folderChecks() {
    let folders: [SupportFolders] = [.base, .indices, .services, .cache]
    for folder in folders {
      do {
        guard !folder.exists else { continue }
        try folder.create()
      } catch {
        #if DEBUG
        print("Create folder error", error)
        #endif
      }
    }
  }
  
  private func setupCache() {
    URLCache.shared = URLCache(
        memoryCapacity: 1024 * 1024 * 5,
        diskCapacity: 1024 * 1024 * 25,
        diskPath: SupportFolders.cache.path.path
    )
  }
  
  @objc private func launchHelper() {
    #if RELEASE
    TonnerreHelper.launch()
    #endif
  }
  
  private func setupSettings() {
    TonnerreSettings.addDefaultSetting()
  }
}
