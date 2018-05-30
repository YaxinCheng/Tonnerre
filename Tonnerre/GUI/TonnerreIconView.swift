//
//  TonnerreIconView.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class TonnerreIconView: NSImageView , ThemeProtocol {
  
  var theme: TonnerreTheme {
    get {
      return TonnerreTheme.currentTheme
    }
    set {
      guard let image = self.image else { return }
      self.image = image.tintedImage(with: newValue.imgColour)
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
