//
//  ProviderItem.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-02.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ProviderItem: SettingItem {
  let displayIdentifier: NSUserInterfaceItemIdentifier = .generalCell
  let settingKey: String?
  
  init(key: String) {
    settingKey = key
  }
  
  func configure(displayCell: SettingCell) {
    displayCell.titleLabel.stringValue = "Test"
    displayCell.contentLabel.stringValue = "Content"
  }
}
