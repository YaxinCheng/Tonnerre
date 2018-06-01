//
//  TonnerreField.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class TonnerreField: NSTextField, ThemeProtocol {
  weak var tonnerreDelegate: TonnerreFieldDelegate?
  var responding: Bool = false
  
  var placeholderColour: NSColor! {
    didSet {
      placeholderAttributedString = NSAttributedString(string: placeholderString ?? "Tonnerre", attributes: [.foregroundColor: placeholderColour, .font: NSFont.systemFont(ofSize: 40)])
    }
  }
  
  var theme: TonnerreTheme {
    set {
      placeholderColour = newValue.placeholderColour
    } get {
      return TonnerreTheme.currentTheme
    }
  }
  
  override func keyDown(with event: NSEvent) {
    switch event.keyCode {
    case 125, 126:// Up/down arrow
      responding = false
    default:
      if !responding {// Used to prevent up arrow key brings the cursor to the beginning
        responding = true
        becomeFirstResponder()
        currentEditor()?.moveToEndOfDocument(nil)
      }
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
    delegate = self
  }
  
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
}

protocol TonnerreFieldDelegate: class {
  func textDidChange(value: String)
}

extension TonnerreField: NSTextFieldDelegate {
  override func controlTextDidChange(_ obj: Notification) {
    guard let textField = obj.object as? TonnerreField, textField === self else { return }
    let text = textField.stringValue
    tonnerreDelegate?.textDidChange(value: text)
  }
}
