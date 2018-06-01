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
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
    delegate = self
  }
  
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    switch event.keyCode {
    case 18...25, 125, 126: return true
    default:
      return super.performKeyEquivalent(with: event)
    }
  }
  
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
  
  func autoComplete(cmd: String) {
    let tokens = stringValue.components(separatedBy: .whitespaces).filter({ !$0.isEmpty })
    guard !tokens.isEmpty else { return }
    if tokens.count > 1 {
      stringValue = tokens[0 ..< tokens.count - 1].joined(separator: " ") + " \(cmd) "
    } else {
      stringValue = "\(cmd) "
    }
    window?.makeFirstResponder(nil)
    DispatchQueue.main.async { [unowned self] in
      self.currentEditor()?.selectedRange = NSMakeRange(0, 0)
      self.currentEditor()?.moveToEndOfDocument(nil)
    }
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
