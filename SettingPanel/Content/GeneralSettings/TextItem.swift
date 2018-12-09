//
//  TextItem.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-09.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct TextItem: SettingItem {
  var settingKey: String? {
    return id.rawValue
  }
  let id: TonnerreSettings.SettingKey
  let name: String
  let content: String
  
  func configure(displayCell: SettingCell) {
    displayCell.titleLabel.stringValue = name
    displayCell.contentLabel.stringValue = content
    displayCell.textField?.stringValue = settingValue ?? ""
  }
  
  let displayIdentifier: NSUserInterfaceItemIdentifier = .textCell
  
  var settingValue: String? {
    get {
      guard let key = settingKey else { return nil }
      let userDefault = UserDefaults.shared
      return userDefault.string(forKey: key)
    } set {
      guard let key = settingKey else { return }
      let userDefault = UserDefaults.shared
      if let value = newValue {
        userDefault.set(value, forKey: key)
      } else {
        userDefault.removeObject(forKey: key)
      }
    }
  }
}
