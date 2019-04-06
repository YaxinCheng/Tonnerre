//
//  DefaultSettingsResource.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct DefaultSettingResource: EnvResource {
  let defaultSettings: [(key: SettingKey, value: SettingValue)]
  
  private let _DEFAULT_SETTINGS = "defaultSettings"
  
  init() {
    let content: Result<[String : String], Error> = PropertyListSerialization.read(fileName: _DEFAULT_SETTINGS)
    switch content {
    case .success(let settings):
      defaultSettings = settings
        .map { (SettingKey(rawValue: $0.key), SettingValue(value: $0.value)) }
        .filter { $0.0 != nil && $0.1 != nil }
        .map { ($0.0!, $0.1!) }
    case .failure(_):
      defaultSettings = []
    }
  }
  
  func export(to env: Environment) {
    for (key, value) in defaultSettings {
      TonnerreSettings.set(value, forKey: key)
    }
  }
}
