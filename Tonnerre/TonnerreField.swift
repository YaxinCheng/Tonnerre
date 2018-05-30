//
//  TonnerreField.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class TonnerreField: NSTextField {
  
  var placeholderColour: NSColor! {
    didSet {
      placeholderAttributedString = NSAttributedString(string: placeholderString ?? "Tonnerre", attributes: [.foregroundColor: placeholderColour, .font: NSFont.systemFont(ofSize: 40)])
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
}
