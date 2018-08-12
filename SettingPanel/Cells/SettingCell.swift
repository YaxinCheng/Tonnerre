//
//  SettingCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

enum SettingCellType: String {
  case text
  case onOff
  case gradient
  
  var identifier: String {
    return rawValue
  }
  
  static var types: [SettingCellType] {
    return [.text, .onOff, .gradient]
  }
}

protocol SettingCell: class {
  var type: SettingCellType { get }
  var detailLabel: NSTextField! { get set }
  var titleLabel: NSTextField! { get set }
  var settingKey: String! { get set }
}

