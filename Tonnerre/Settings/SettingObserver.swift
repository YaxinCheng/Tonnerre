//
//  SettingObserver.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-26.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

class SettingObserver: NSObject {
  private class WeakRef<T: SettingSubscriber>: SettingSubscriber {
    weak var value: T!
    
    init(_ value: T) {
      self.value = value
    }
    
    var subscribedKey: SettingKey {
      return value.subscribedKey
    }
    
    func settingDidChange(_ changes: [NSKeyValueChangeKey : Any]) {
      value.settingDidChange(changes)
    }
  }
  
  private var subscribers: [SettingKey : [SettingSubscriber]] = [:]
  private let userDefault = UserDefaults.shared
  
  func register<T: SettingSubscriber>(subscriber: T) {
    subscribers[subscriber.subscribedKey, default: []].append(subscriber)
    guard (subscribers[subscriber.subscribedKey] ?? []).count == 1 else { return }
    userDefault.addObserver(self, forKeyPath: subscriber.subscribedKey.rawValue,
                            options: [.new, .initial], context: nil)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard
      let keyPath = keyPath,
      let settingKey = SettingKey(rawValue: keyPath)
    else { return }
    subscribers[settingKey]?.forEach { $0.settingDidChange(change ?? [:]) }
  }
}
