//
//  TextFieldCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-02.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TextFieldCell: SettingCell {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    textField?.delegate = self
  }
}

extension TextFieldCell: NSTextFieldDelegate {
  func controlTextDidEndEditing(_ obj: Notification) {
    guard
      (obj.object as? NSTextField) === textField,
      let value = textField?.stringValue,
      (obj.userInfo?["NSTextMovement"] as? Int) == 16
    else { return }
    var textItem = item as? TextItem
    textItem?.settingValue = value
  }
}
