//
//  Environment.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

/// System setup environment
final class Environment {
  /// Arguments in the environment
  private var resourceTypes: [EnvResource.Type]
  /// Resources have futher functions should be kept here to avoid being released
  var persistedResource: [EnvResource] = []
  /// Setting observer
  let settingObserver: SettingObserver
  
  init() {
    resourceTypes = [CacheResource.self, SupportFoldersResource.self,
                DefaultSettingResource.self, HelperResource.self,
                ProviderMapResource.self, ClipboardResource.self]
    settingObserver = SettingObserver()
  }
  
  /// Setup environment resources
  func setup() {
    while !resourceTypes.isEmpty {
      resourceTypes.removeFirst().init().export(to: self)
    }
  }
}
