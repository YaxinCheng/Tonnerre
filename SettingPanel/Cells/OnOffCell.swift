//
//  OnOffCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class OnOffCell: NSView, SettingCell {
  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var detailLabel: NSTextField!
  let type: SettingCellType = .onOff
  
  private let toggle: Switch
  
  required init?(coder decoder: NSCoder) {
    toggle = {
      $0.animationSpeed = 3
      $0.animationProgress = 0
      return $0
    }(Switch(name: "Switch"))
    super.init(coder: decoder)
   
    toggle.delegate = self
    toggle.frame = NSRect(x: frame.width - frame.height, y: frame.height/4, width: frame.height, height: frame.height)
    addSubview(toggle)
  }
}

extension OnOffCell: SwitchDelegate {
  func valueChanged(sender: Switch) {
    print("switch")
  }
}
