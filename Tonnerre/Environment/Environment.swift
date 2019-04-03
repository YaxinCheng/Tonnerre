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
  private var initialSetupResources: [EnvResource.Type]
  /// Arguments in the environment
  private var resourceTypes: [EnvResource.Type]
  /// Resources have futher functions should be kept here to avoid being released
  var persistedResource: [EnvResource] = []
  /// Setting observer
  let settingObserver: SettingObserver
  
  init() {
    initialSetupResources = [DefaultSettingResource.self]
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
    Token.initialStartup.execute { [unowned self] in
      while !self.initialSetupResources.isEmpty {
        initialSetupResources.removeFirst().init().export(to: self)
      }
    }
  }
}

extension Environment {
  enum Token: String {
    case initialStartup
    
    func execute(_ action: ()->()) {
      guard UserDefaults.shared.bool(forKey: rawValue) else { return }
      UserDefaults.shared.set(true, forKey: rawValue)
      action()
    }
  }
}
