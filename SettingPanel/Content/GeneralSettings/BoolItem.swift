//
//  BoolItem.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-17.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct BoolItem: SettingItem {
  var settingKey: String? {
    return id.rawValue
  }
  let id: SettingKey
  let name: String
  let content: String
  
  func configure(displayCell: SettingCell) {
    displayCell.titleLabel.stringValue = name
    displayCell.contentLabel.stringValue = content
    let boolCell = displayCell as! BoolCell
    switch settingValue {
    case true : boolCell.switchControl.state = .on
    case false: boolCell.switchControl.state = .off
    }
  }
  
  let displayIdentifier: NSUserInterfaceItemIdentifier = .boolCell
  
  var settingValue: Bool {
    get {
      return TonnerreSettings.get(fromKey: id)?.rawValue as? Bool ?? false
    } set {
      TonnerreSettings.set(.bool(newValue), forKey: id)
    }
  }
}
