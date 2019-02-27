//
//  Environment.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Environment {
  private class ObserverDecorator: SettingSubscriber, EnvService {
    let service: EnvService
    let subscribedKey: SettingKey
    private let standard: ([NSKeyValueChangeKey : Any]) -> Bool
    
    init(service: EnvService, subscribedKey: SettingKey,
         standard: @escaping ([NSKeyValueChangeKey : Any])->Bool) {
      self.service = service
      self.subscribedKey = subscribedKey
      self.standard = standard
    }
    
    func settingDidChange(_ changes: [NSKeyValueChangeKey : Any]) {
      if standard(changes) { setup() }
      else { tearDown() }
    }
    
    func setup() { service.setup() }
    func tearDown() { service.tearDown() }
  }
  
  private var services: [EnvService]
  
  init() {
    let clipboardObserver = ObserverDecorator(service: ClipboardService.monitor, subscribedKey: .disabledServices) {
      switch $0[.newKey] {
      case let ids as [String]:
        return ids.contains(BuiltInProviderMap.extractID(from: ClipboardService.self))
      default: return false
      }
    }
    services = [CacheEnvService(), SupportFoldersEnvService(),
                DefaultSettingEnvService(), HelperEnvService(),
                ProviderMap.shared, clipboardObserver]
  }
  
  func setup() {
    services.forEach { $0.setup() }
  }
}
