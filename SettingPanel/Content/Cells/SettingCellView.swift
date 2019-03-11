//
//  SettingCellView.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2019-03-11.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol SettingCellViewDelegate: class {
  func menuWillOpen(view: NSView, menu: NSMenu, with event: NSEvent)
}

class SettingCellView: NSView {
  
  weak var delegate: SettingCellViewDelegate?
  
  override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
    delegate?.menuWillOpen(view: self, menu: menu, with: event)
  }
  
  override func updateLayer() {
    layer?.backgroundColor = NSColor(named: "CellColor")?.cgColor
    super.updateLayer()
  }
}
