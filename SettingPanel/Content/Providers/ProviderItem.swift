//
//  ProviderItem.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ProviderItem: SettingItem {
  
  var settingKey: String? {
    return id
  }
  let id: String
  let keyword: String
  let name: String
  let content: String
  
  func configure(displayCell: SettingCell) {
    displayCell.titleLabel.stringValue = name
    displayCell.contentLabel.stringValue = "(\(keyword)) \(content)"
    (displayCell as? GeneralCell)?.switchControl.state = {
      switch DisableManager.shared.isDisabled(providerID: id) {
      case false: return .on
      case true : return .off
      }
    }()
  }
  
  let displayIdentifier: NSUserInterfaceItemIdentifier = .generalCell
}
