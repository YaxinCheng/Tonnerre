//
//  BaseWindow.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import HotKey

class BaseWindow: NSWindow {
  override var canBecomeKey: Bool {
    return true
  }
  
  var isHidden: Bool = false {
    didSet {
      if isHidden {
        let notification = Notification(name: .windowIsHiding)
        NotificationCenter.default.post(notification)
        orderOut(self)
      } else {
        makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
      }
    }
  }
  
  let hotkey: HotKey
  
  override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
    hotkey = HotKey(key: .space, modifiers: [.option, .command])
    super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    hotkey.keyDownHandler = { [weak self] in
      self?.isHidden = !(self?.isHidden ?? true)
    }
    isMovableByWindowBackground = true
    isMovable = true
    folderChecks()
    NotificationCenter.default.addObserver(self, selector: #selector(windowDidMove(notification:)), name: NSWindow.didMoveNotification, object: nil)
  }
  
  @objc private func windowDidMove(notification: Notification) {
    let userDefault = UserDefaults.standard
    let (x, y) = (frame.origin.x, frame.origin.y)
    userDefault.set(x, forKey: StoredKeys.designatedX.rawValue)
    userDefault.set(y, forKey: StoredKeys.designatedY.rawValue)
  }
  
  private func folderChecks() {
    let fileManager = FileManager.default
    guard
      let appSupportPath = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
      let bundleID = Bundle.main.bundleIdentifier
      else { return }
    let dataFolderPath = appSupportPath.appendingPathComponent(bundleID)
    let indexFolder = dataFolderPath.appendingPathComponent("Indices")
    
    if !fileManager.fileExists(atPath: indexFolder.path) {
      let userDefault = UserDefaults.standard
      userDefault.set(dataFolderPath, forKey: StoredKeys.appSupportDir.rawValue)
      do {
        try fileManager.createDirectory(at: indexFolder, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("Cannot create the app support folder")
      }
    }
  }
}
