//
//  DSEnforcement.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Add default setting values to the UserDefault
*/
struct TonnerreSettings {
  private static let userDefault = UserDefaults.shared
  
  enum SettingKey: String {
    case python
    case defaultProvider = "Tonnerre.Provider.Default"
  }
  
  private static let defaultSettings: [(key: SettingKey, value: Any)] = [
     (.python, "/usr/bin/python"),
     (.defaultProvider, "Tonnerre.Provider.BuiltIn.GoogleSearch")
  ]
  
  static func addDefaultSetting(reset: Bool = false) {
    let doneExecuting = userDefault.bool(forKey: "settings:finished") || reset
    guard !doneExecuting else { return }
    for (key, value) in defaultSettings {
      userDefault.set(value, forKey: key)
    }
    userDefault.set(true, forKey: "settings:finished")
  }
}

extension UserDefaults {
  func set(_ value: Any?, forKey settingKey: TonnerreSettings.SettingKey) {
    set(value, forKey: "settings:" + settingKey.rawValue)
  }
  
  subscript(settingKey: TonnerreSettings.SettingKey) -> Any? {
    return object(forKey: "settings:" + settingKey.rawValue)
  }
}
