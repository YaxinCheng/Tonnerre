//
//  CellView.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-02.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class CellView: NSView {
  
  override func updateLayer() {
    layer?.backgroundColor = NSColor(named: "CellColor")?.cgColor
    super.updateLayer()
  }
  
}
