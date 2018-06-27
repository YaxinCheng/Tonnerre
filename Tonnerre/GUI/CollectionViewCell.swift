//
//  CollectionViewCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-27.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class CollectionViewCell: NSView {
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  private static func initView(view: NSView) {
    view.canDrawSubviewsIntoLayer = true
    view.wantsLayer = true
  }
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    type(of: self).initView(view: self)
  }
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    type(of: self).initView(view: self)
  }
  override var canDraw: Bool { return true }
}
