//
//  Environment.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

/// System setup environment
struct Environment {
  /// Arguments in the environment
  private let args: [EnvArg]
  /// Setting observer
  private let settingObserver: SettingObserver
  
  init() {
    args = [CacheArg(), SupportFoldersArg(),
                DefaultSettingArg(), HelperArg(),
                ProviderMapArg(), ClipboardArg()]
    settingObserver = SettingObserver()
  }
  
  /// Setup environment with arguments
  func setup() {
    for arg in args {
      if let subscriber = arg as? SettingSubscriber {
        settingObserver.register(subscriber: subscriber)
      }
      arg.setup()
    }
  }
}
