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
    level = .mainMenu
    isOpaque = false
    backgroundColor = .clear
    collectionBehavior.insert(.canJoinAllSpaces)
    DistributedNotificationCenter.default().addObserver(self, selector: #selector(launchHelper), name: .helperAppDidExit, object: nil)
    
    folderChecks()
    setupCache()
    launchHelper()
    setupSettings()
  }
  
  private func folderChecks() {
    let fileManager = FileManager.default
    guard
      let appSupportPath = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
      let bundleID = Bundle.main.bundleIdentifier
      else { return }
    let dataFolderPath = appSupportPath.appendingPathComponent(bundleID)
    let userDefault = UserDefaults.shared
    userDefault.set(dataFolderPath, forKey: .appSupportDir)
    let indexFolder = dataFolderPath.appendingPathComponent("Indices")
    let servicesFolder = dataFolderPath.appendingPathComponent("Services")
    let cacheFolder = dataFolderPath.appendingPathComponent("Cache")
    
    for path in [indexFolder, servicesFolder, cacheFolder] {
      if !fileManager.fileExists(atPath: path.path) {
        do {
          try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
          #if DEBUG
          print(error)
          #endif
        }
      }
    }
  }
  
  private func setupCache() {
    let cache = URLCache(memoryCapacity: 1024 * 1024 * 5, diskCapacity: 1024 * 1024 * 25, diskPath: {
      let userDefault = UserDefaults.shared
      let appSupFolder = userDefault.url(forKey: .appSupportDir)!
      return appSupFolder.appendingPathComponent("Cache").path
    }())
    URLCache.shared = cache
  }
  
  @objc private func launchHelper() {
    #if RELEASE
    let helperLocation = Bundle.main.bundleURL.appendingPathComponent("/Contents/Applications/TonnerreIndexHelper.app")
    let workspace = NSWorkspace.shared
    _ = try? workspace.launchApplication(at: helperLocation, options: .andHide, configuration: [:])
    #endif
  }
  
  private func setupSettings() {
    TonnerreSettings.addDefaultSetting()
  }
}
