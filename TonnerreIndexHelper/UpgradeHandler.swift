//
//  UpgradeHandler.swift
//  TonnerreIndexHelper
//
//  Created by Yaxin Cheng on 2018-09-27.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class UpgradeHandler {
  private var currentSystemVersion: String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }
  private var lastSystemVersion: String {
    get {
      let userDefault = UserDefaults.standard
      if let versionString = userDefault.string(forKey: "SystemVersion") {
        return versionString
      } else {
        userDefault.set(currentSystemVersion, forKey: "SystemVersion")
        return currentSystemVersion
      }
    } set {
      let userDefault = UserDefaults.standard
      userDefault.set(newValue, forKey: "SystemVersion")
    }
  }
  
  func handle() {
    guard currentSystemVersion != lastSystemVersion else { return }
    let fileManager = FileManager.default
    let appSupDir = UserDefaults.shared.url(forKey: .appSupportDir)!
    let defaultIndexPath = appSupDir.appendingPathComponent("Indices/default.tnidx")
    do {
      try fileManager.removeItem(at: defaultIndexPath)
      lastSystemVersion = currentSystemVersion
    } catch {
      #if DEBUG
      print("error removing default index", error)
      #endif
    }
  }
}
