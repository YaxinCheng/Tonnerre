//
//  SettingKey.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-26.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

/// Existing keys for settings
enum SettingKey: String {
  case python = "settings:python"
  case defaultProvider = "Tonnerre.Provider.Default"
  case clipboardLimit = "Tonnerre.Provider.BuiltIn.ClipboardService:limit"
  case warnBeforeExit = "settings:warnBeforeExit"
  case disabledServices = "Tonnerre.Providers.Disabled.IDs"
  case helperDidExit = "Tonnerre.helper.didExit"
}
