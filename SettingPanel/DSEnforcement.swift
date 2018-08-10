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
struct DSEnforcement {
  private let userDefault = UserDefaults(suiteName: "Tonnerre")!
  
  private let settings: [(key: String, value: Any)] = [
     ("python", "/usr/bin/python")
    ,("themeFollowsSystem", true)
  ]
  
  func execute(reset: Bool = false) {
    let doneExecuting = userDefault.bool(forKey: "settings:finished") || reset
    guard !doneExecuting else { return }
    for (key, value) in settings {
      let elementKey = "settings:" + key
      userDefault.set(value, forKey: elementKey)
    }
    userDefault.set(true, forKey: "settings:finished")
  }
}
