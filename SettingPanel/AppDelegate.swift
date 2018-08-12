//
//  AppDelegate.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationWillFinishLaunching(_ notification: Notification) {
    TonnerreSettings.addDefaultSetting()
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}

