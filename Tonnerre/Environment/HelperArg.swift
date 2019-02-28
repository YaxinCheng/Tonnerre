//
//  HelperArg.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

class HelperArg: EnvArg, SettingSubscriber {
  let subscribedKey: SettingKey = .helperDidExit
  
  func setup() {
    #if RELEASE
    TonnerreHelper.launch()
    #endif
  }
  
  func tearDown() {
    #if RELEASE
    TonnerreHelper.terminate()
    #endif
  }
  
  func settingDidChange(_ changes: [NSKeyValueChangeKey : Any]) {
    switch changes[.newKey] {
    case let exitFlag as Bool:
      if exitFlag == true { setup() }
      else { tearDown() }
    default: return
    }
  }
}
