//
//  SettingObserver.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-26.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

/// The class that actually listens to changes in the setting
/// and calls the subscribers
class SettingObserver: NSObject {
  /// Weak reference wrap. Used to wrap subscribers
  private class WeakRef: SettingSubscriber {
    weak var value: SettingSubscriber!
    
    init(_ value: SettingSubscriber) {
      self.value = value
    }
    
    var subscribedKey: SettingKey {
      return value.subscribedKey
    }
    
    func settingDidChange(_ changes: [NSKeyValueChangeKey : Any]) {
      value.settingDidChange(changes)
    }
  }
  
  /// All the subscribers registered
  private var subscribers: [SettingKey : [SettingSubscriber]] = [:]
  private let userDefault = UserDefaults.shared
  
  /// Register subscriber with the key is listens to
  /// - parameter subscriber: subscriber that listens to a certain key
  func register(subscriber: SettingSubscriber) {
    let weakWrapped = WeakRef(subscriber)
    subscribers[subscriber.subscribedKey, default: []].append(weakWrapped)
    guard (subscribers[weakWrapped.subscribedKey] ?? []).count == 1 else { return }
    userDefault.addObserver(self, forKeyPath: weakWrapped.subscribedKey.rawValue,
                            options: [.new, .initial], context: nil)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard
      let keyPath = keyPath,
      let settingKey = SettingKey(rawValue: keyPath)
    else { return }
    subscribers[settingKey]?.forEach { $0.settingDidChange(change ?? [:]) }
  }
  
  deinit {
    for key in subscribers.keys {
      userDefault.removeObserver(self, forKeyPath: key.rawValue)
    }
  }
}
