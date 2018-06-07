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
    setupCache()
    launchHelper()
    NotificationCenter.default.addObserver(self, selector: #selector(windowDidMove(notification:)), name: NSWindow.didMoveNotification, object: nil)
    DistributedNotificationCenter.default().addObserver(self, selector: #selector(launchHelper), name: .helperAppDidExit, object: nil)
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
    let userDefault = UserDefaults(suiteName: "Tonnerre")!
    userDefault.set(dataFolderPath, forKey: StoredKeys.appSupportDir.rawValue)
    let indexFolder = dataFolderPath.appendingPathComponent("Indices")
    let servicesFolder = dataFolderPath.appendingPathComponent("Services")
    let cacheFolder = dataFolderPath.appendingPathComponent("Cache")
    
    for path in [indexFolder, servicesFolder, cacheFolder] {
      if !fileManager.fileExists(atPath: path.path) {
        do {
          try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        } catch { print(error) }
      }
    }
  }
  
  private func setupCache() {
    let cache = URLCache(memoryCapacity: 1024 * 1024, diskCapacity: 1024 * 1024 * 10, diskPath: {
      let userDefault = UserDefaults.standard
      let appSupFolder = userDefault.url(forKey: StoredKeys.appSupportDir.rawValue)!
      return appSupFolder.appendingPathComponent("Cache").path
    }())
    URLCache.shared = cache
  }
  
  @objc private func launchHelper() {
    let helperLocation = Bundle.main.bundlePath.appending("/Contents/Resources/TonnerreIndexHelper.app")
    let workspace = NSWorkspace.shared
    _ = try? workspace.launchApplication(at: URL(fileURLWithPath: helperLocation), options: .andHide, configuration: [:])
  }
}
