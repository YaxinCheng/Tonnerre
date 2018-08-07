//
//  SettingCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class SettingCell: NSView {
  enum CellType: String {
    case text
    
    var identifier: String {
      return rawValue
    }
    
    static var types: [CellType] {
      return [.text]
    }
  }
  
  var type: CellType { fatalError("please override in subclasses") }
  
  override func copy() -> Any {
    return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))!
  }
}


