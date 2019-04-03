//
//  DefaultSettingsResource.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct DefaultSettingResource: EnvResource {
  let defaultSettings: [(key: SettingKey, value: SettingValue)] = [
    (.python, "/usr/bin/python"),
    (.defaultProvider, "Tonnerre.Provider.BuiltIn.GoogleSearch"),
    (.clipboardLimit, 9),
    (.warnBeforeExit, true),
    (.disabledServices, ["Tonnerre.Provider.BuiltIn.SafariBMService",
                         "Tonnerre.Provider.BuiltIn.ChromeBMService"])
  ]
  
  func export(to env: Environment) {
    for (key, value) in defaultSettings {
      TonnerreSettings.set(value, forKey: key)
    }
  }
}
