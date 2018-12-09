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
    case python = "settings:python"
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
      set(value, forKey: key)
    }
    userDefault.set(true, forKey: "settings:finished")
  }
  
  static func set(_ value: Any, forKey key: SettingKey) {
    userDefault.set(value, forKey: key.rawValue)
  }
  
  static func get(fromKey key: SettingKey) -> Any? {
    return userDefault.object(forKey: key.rawValue)
  }
}
