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
    displayCell.textField?.stringValue = settingValueDisplay
  }

  let displayIdentifier: NSUserInterfaceItemIdentifier = .textCell

  var settingValue: SettingType? {
    get {
      return TonnerreSettings.get(fromKey: id)
    } set {
      if let value = newValue {
        TonnerreSettings.set(value, forKey: id)
      } else {
        TonnerreSettings.remove(forKey: id)
      }
    }
  }
  
  var settingValueDisplay: String {
    guard let value = settingValue else { return "" }
    switch value {
    case .string(let stringValue): return stringValue
    default: return String(reflecting: value.rawValue)
    }
  }
}
