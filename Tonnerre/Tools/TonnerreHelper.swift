//
//  TonnerreHelper.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-24.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

enum TonnerreHelper {
  static var identifier: String {
    return "com.ycheng.Tonnerre.helper"
  }
  
  weak static var instance: NSRunningApplication? {
    return NSRunningApplication.runningApplications(withBundleIdentifier: identifier).first
  }

  static var isRunning: Bool {
    return instance != nil
  }
  
  static func launch() {
    guard instance == nil else { return }
    let path = Bundle.main.bundleURL.appendingPathComponent("/Contents/Applications/TonnerreIndexHelper.app")
    do {
      try NSWorkspace.shared.launchApplication(at: path, options: .andHide, configuration: [:])
    } catch {
      Logger.error(file: TonnerreHelper.self, "TonnerreHelper Launch Error: %{PUBLIC}@", error.localizedDescription)
    }
  }
  
  static func terminate() {
    guard let runningInstance = instance else { return }
    runningInstance.terminate()
  }
}
