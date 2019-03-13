//
//  SettingSubscriber.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-26.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

/// Subscriber listens to setting changes
protocol SettingSubscriber: class {
  /// The setting key this subscriber listens to
  var subscribedKey: SettingKey { get }
  /// The function called when the subscribed key has been changed
  /// - parameter changes: a dictionary returned from KVO which contains
  ///     the changes and the original value
  func settingDidChange()
}
