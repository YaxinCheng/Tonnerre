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
  
  var identifier: String {
    return rawValue
  }
  
  static var types: [SettingCellType] {
    return [.text]
  }
}

protocol SettingCell {
  var type: SettingCellType { get }
  func copy() -> Self
}

extension SettingCell {
  func copy() -> Self {
    return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! Self
  }
}
