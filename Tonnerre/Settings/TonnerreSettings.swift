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
    case clipboardLimit = "Tonnerre.Provider.BuiltIn.ClipboardService:limit"
    case warnBeforeExit = "settings:warnBeforeExit"
    case disabledServices = "Tonnerre.Providers.Disabled.IDs"
  }
  
  private static let defaultSettings: [(key: SettingKey, value: SettingType)] = [
     (.python, "/usr/bin/python"),
     (.defaultProvider, "Tonnerre.Provider.BuiltIn.GoogleSearch"),
     (.clipboardLimit, 9),
     (.warnBeforeExit, true),
     (.disabledServices, ["Tonnerre.Provider.BuiltIn.SafariBMService",
                          "Tonnerre.Provider.BuiltIn.ChromeBMService"])
  ]
  
  static func addDefaultSetting(reset: Bool = false) {
    let doneExecuting = userDefault.bool(forKey: "settings:finished") || reset
    guard !doneExecuting else { return }
    for (key, value) in defaultSettings {
      set(value, forKey: key)
    }
    userDefault.set(true, forKey: "settings:finished")
  }
  
  static func set(_ value: SettingType, forKey key: SettingKey) {
    userDefault.set(value.rawValue, forKey: key.rawValue)
  }
  
  static func get(fromKey key: SettingKey) -> SettingType? {
    guard let value = userDefault.value(forKey: key.rawValue) else { return nil }
    switch value {
    case let boolVal as Bool: return .bool(boolVal)
    case let intVal as Int: return .int(intVal)
    case let stringVal as String: return .string(stringVal)
    case let arrayVal as [Any]: return .array(arrayVal)
    default: return nil
    }
  }
  
  static func remove(forKey key: SettingKey) {
    userDefault.removeObject(forKey: key.rawValue)
  }
}
