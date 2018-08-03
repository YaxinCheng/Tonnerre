//
//  PlaceholderField.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class PlaceholderField: NSTextField, ThemeProtocol {
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
  
  private var placeholderColour: NSColor! {
    didSet {
      placeholderAttributedString = NSAttributedString(string: placeholderString ?? "", attributes: [.foregroundColor: placeholderColour, .font: NSFont.systemFont(ofSize: 35)])
    }
  }
  
  var theme: TonnerreTheme {
    set {
      placeholderColour = newValue.placeholderColour
    } get {
      return .current
    }
  }
  
  override var placeholderString: String? {
    didSet {
      placeholderAttributedString = NSAttributedString(string: placeholderString ?? "", attributes: [.foregroundColor: placeholderColour, .font: NSFont.systemFont(ofSize: 35)])
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    guard event.clickCount == 2 else { return }
    guard var designedFrame = window?.frame, let mainScreen = NSScreen.main else { return }
    designedFrame.origin.x = mainScreen.frame.width/2 - designedFrame.width/2
    designedFrame.origin.y = mainScreen.frame.height * 5 / 6 - designedFrame.height
    window?.setFrame(designedFrame, display: true)
  }
}
