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
      guard let value = TonnerreSettings.get(fromKey: id) else { return nil }
      if let stringValue = value as? String {
        return stringValue
      } else {
        return String(reflecting: value)
      }
    } set {
      if let value = newValue {
        TonnerreSettings.set(value, forKey: id)
      } else {
        TonnerreSettings.remove(forKey: id)
      }
    }
  }
}
