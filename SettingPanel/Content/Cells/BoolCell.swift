//
//  BoolCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-17.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class BoolCell: SettingCell, SwitchDelegate {
  
  @IBOutlet weak var switchControl: Switch! {
    didSet {
      switchControl.delegate = self
    }
  }
  
  func valueDidChange(sender: Any) {
    guard
      let switchSender = sender as? Switch,
      switchSender === switchControl,
      var item = item as? BoolItem
    else { return }
    item.settingValue = switchSender.state == .on
  }
}
