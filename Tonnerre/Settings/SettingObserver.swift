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
class SettingObserver {
  /// Weak reference wrap. Used to wrap subscribers
  private class WeakRef: SettingSubscriber {
    weak var value: SettingSubscriber!
    
    init(_ value: SettingSubscriber) {
      self.value = value
    }
    
    var subscribedKey: SettingKey {
      return value.subscribedKey
    }
    
    func settingDidChange() {
      value.settingDidChange()
    }
  }
  
  /// All the subscribers registered
  private var subscribers: [SettingKey : SettingSubscriber] = [:]
  
  /// Register subscriber with the key is listens to
  /// - parameter subscriber: subscriber that listens to a certain key
  func register(subscriber: SettingSubscriber) {
    let weakWrapped = WeakRef(subscriber)
    subscribers[subscriber.subscribedKey] = weakWrapped
    updateKeys()
  }
  
  func unregister(subscriber: SettingSubscriber) {
    subscribers[subscriber.subscribedKey] = nil
    updateKeys()
  }
  
  private func updateKeys() {
    let keys = Array(subscribers.keys).map { $0.rawValue }
    UserDefaults.shared.set(keys, forKey: .subscribedKeys)
  }
  
  @objc func settingDidChange(_ notification: Notification) {
    guard
      let objectKey = notification.object as? String,
      let settingKey = SettingKey(rawValue: objectKey)
    else { return }
    subscribers[settingKey]?.settingDidChange()
  }
  
  init() {
    DistributedNotificationCenter.default().addObserver(self, selector: #selector(settingDidChange(_:)), name: .settingDidChange, object: nil)
  }
}
