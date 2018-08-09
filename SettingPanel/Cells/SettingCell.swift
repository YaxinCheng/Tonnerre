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
  
  var identifier: String {
    return rawValue
  }
  
  static var types: [SettingCellType] {
    return [.text, .onOff]
  }
}

protocol SettingCell: class {
  var type: SettingCellType { get }
  var detailLabel: NSTextField! { get set }
  var titleLabel: NSTextField! { get set }
}

