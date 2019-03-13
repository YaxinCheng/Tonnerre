//
//  ClipboardResource.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

final class ClipboardResource: EnvResource, SettingSubscriber {
  private let clipboardMonitor: ClipboardMonitor
  let subscribedKey: SettingKey = .disabledServices
  
  init() {
    clipboardMonitor = ClipboardMonitor(interval: 1, repeat: true) { (value, type) in
      let limit = TonnerreSettings.get(fromKey: .clipboardLimit)?.rawValue as? Int ?? 9
      CBRecord.insert(value: value, type: type.rawValue, limit: max(limit, 1))
    }
  }
  
  func export(to env: Environment) {
    clipboardMonitor.start()
    env.settingObserver.register(subscriber: self)
    env.persistedResource.append(self)
  }
  
  func settingDidChange() {
    switch TonnerreSettings.get(fromKey: subscribedKey) {
    case .array(let disabledIds)? where disabledIds is [String]:
      if (disabledIds as! [String]).contains(BuiltInProviderMap.extractID(from: ClipboardService.self)) {
        clipboardMonitor.start()
      } else { clipboardMonitor.stop() }
    default: return
    }
  }
}
