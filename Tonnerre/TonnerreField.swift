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
    guard let _ = UserDefaults.standard.value(forKey: StoredKeys.AppleInterfaceStyle.rawValue) as? String else {
      placeholderColour = NSColor(calibratedRed: 61/255, green: 61/255, blue: 61/255, alpha: 0.4)
      return
    }
    placeholderColour = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.4)
  }
  
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
}
