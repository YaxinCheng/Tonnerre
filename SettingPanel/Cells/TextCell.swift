//
//  TextCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TextCell: NSView, SettingCell {
  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var detailLabel: NSTextField!
  @IBOutlet weak var textField: NSTextField!
  
  let type: SettingCellType = .text
  var settingKey: String!
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let userDefault = UserDefaults(suiteName: "Tonnerre")!
    let text = userDefault.string(forKey: settingKey) ?? ""
    textField.stringValue = text
    window?.makeFirstResponder(nil)
//    textField.currentEditor()?.selectedRange = NSRange(location: text.count, length: 0)
  }
}
