//
//  PlaceholderField.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class PlaceholderField: NSTextField, ThemeProtocol {
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
  
  private var placeholderColour: NSColor! {
    didSet {
      placeholderAttributedString = NSAttributedString(string: placeholderString ?? "Tonnerre", attributes: [.foregroundColor: placeholderColour, .font: NSFont.systemFont(ofSize: 35)])
    }
  }
  
  var theme: TonnerreTheme {
    set {
      placeholderColour = newValue.placeholderColour
    } get {
      return .current
    }
  }
  
  func reset() {
    placeholderAttributedString = NSAttributedString(string: "Tonnerre", attributes: [.foregroundColor: placeholderColour, .font: NSFont.systemFont(ofSize: 35)])
  }
  
  func empty() {
    placeholderAttributedString = NSAttributedString(string: "", attributes: [.foregroundColor: placeholderColour, .font: NSFont.systemFont(ofSize: 35)])
  }
}
