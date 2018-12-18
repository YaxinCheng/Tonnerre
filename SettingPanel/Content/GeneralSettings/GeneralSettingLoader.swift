//
//  GeneralSettingLoader.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-09.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct GeneralSettingLoader {
  let settings: [(TonnerreSettings.SettingKey, String, String, NSUserInterfaceItemIdentifier)] = [
    python, warnBeforeExit, cbLimit
  ]
  
  private static let python = (TonnerreSettings.SettingKey.python,
                               "Python Interpreter",
                               "Set your python interpreter here. This interpreter will be used to execute all the python-based .tne service providers. Warning, if you choose the incompatible version against the scripts, the scripts may not be executed correctly",
                               NSUserInterfaceItemIdentifier.textCell)
  private static let warnBeforeExit = (TonnerreSettings.SettingKey.warnBeforeExit,
                                       "Warn before exit",
                                       "When enabled, user double click \(String.CMD) Q to exit the program",
                                       NSUserInterfaceItemIdentifier.boolCell)
  private static let cbLimit = (TonnerreSettings.SettingKey.clipboardLimit,
                                "ClipboardService",
                                "Set the number of clipboard records you want to save here (the min number is 1)",
                                NSUserInterfaceItemIdentifier.textCell
                                )
}
