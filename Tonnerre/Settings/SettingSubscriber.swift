//
//  SettingSubscriber.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-26.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol SettingSubscriber: class {
  var subscribedKey: SettingKey { get }
  func settingDidChange(_ changes: [NSKeyValueChangeKey : Any])
}
