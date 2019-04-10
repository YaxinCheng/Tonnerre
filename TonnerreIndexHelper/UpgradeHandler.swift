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
      return userDefault.string(forKey: "SystemVersion") ?? currentSystemVersion
    } set {
      let userDefault = UserDefaults.standard
      userDefault.set(newValue, forKey: "SystemVersion")
    }
  }
  
  func handle() {
    guard currentSystemVersion != lastSystemVersion else { return }
    let fileManager = FileManager.default
    let indicesPath = SupportFolders.indices.path
    let defaultIndexPath = indicesPath.appendingPathComponent("default.tnidx")
    do {
      try fileManager.removeItem(at: defaultIndexPath)
      lastSystemVersion = currentSystemVersion
    } catch {
      Logger.error(file: UpgradeHandler.self, "Removing Default Index Error: %{PUBLIC}@", error.localizedDescription)
    }
  }
}
