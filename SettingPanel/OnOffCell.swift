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
  
  var disabled: Bool = true
  
  private let toggleAnimation: Switch
  
  required init?(coder decoder: NSCoder) {
    toggleAnimation = Switch(name: "Switch")
    super.init(coder: decoder)
   
    toggleAnimation.frame = NSRect(x: frame.width - frame.height, y: 0, width: frame.height, height: frame.height)
    toggleAnimation.animationSpeed = 3
    toggleAnimation.animationProgress = 0
    addSubview(toggleAnimation)
  }
}

extension OnOffCell: SwitchDelegate {
  func valueChanged(sender: Switch) {
    
  }
}
