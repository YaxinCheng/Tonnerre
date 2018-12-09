//
//  GeneralSettingLoader.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-09.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct GeneralSettingLoader {
  let settings: [(TonnerreSettings.SettingKey, String, String)] = [
    python
  ]
  
  private static let python = (TonnerreSettings.SettingKey.python,
                               "Python Interpreter",
                               "Set your python interpreter here. This interpreter will be used to execute all the python-based .tne service providers. Warning, if you choose the incompatible version against the scripts, the scripts may not be executed correctly")
}
