//
//  SettingView.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class SettingView: NSScrollView {
  
  private var contentHeight: NSLayoutConstraint!
  
  override var frame: NSRect {
    didSet {
      contentHeight.constant = frame.height
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    guard
      let ch = documentView?.constraints.filter({ $0.identifier == "contentHeight" }).first
    else { fatalError("View should contain a layout constraint with identifier \"contentHeight\"") }
    contentHeight = ch
  }
}
