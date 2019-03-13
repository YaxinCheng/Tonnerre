//
//  DSEnforcement.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/// Add default setting values to the UserDefault
struct TonnerreSettings {
  private static let userDefault = UserDefaults.shared
  
  static func set(_ value: SettingValue, forKey key: SettingKey) {
    userDefault.set(value.rawValue, forKey: key.rawValue)
    guard
      let subscribedKeys = userDefault.array(forKey: "subscribedKeys") as? [String],
      subscribedKeys.contains(key.rawValue)
    else { return }
    DistributedNotificationCenter.default().post(name: .settingDidChange, object: key.rawValue)
  }
  
  static func get(fromKey key: SettingKey) -> SettingValue? {
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
