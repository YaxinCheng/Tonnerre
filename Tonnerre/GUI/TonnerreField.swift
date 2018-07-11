//
//  TonnerreField.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class TonnerreField: NSTextField, ThemeProtocol {
  
  private var placeholderColour: NSColor! {
    didSet {
      placeholderAttributedString = NSAttributedString(string: placeholderString ?? "Tonnerre", attributes: [.foregroundColor: placeholderColour, .font: NSFont.systemFont(ofSize: 35)])
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    NotificationCenter.default.addObserver(forName: .windowIsHiding, object: nil, queue: .main) { [weak self] _ in
      self?.stringValue = ""
    }
  }
  
  var theme: TonnerreTheme {
    set {
      placeholderColour = newValue.placeholderColour
      textColor = newValue.imgColour
    } get {
      return .currentTheme
    }
  }
  
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    switch event.keyCode {
    case 18...25, 36, 49, 53, 76, 125, 126: return true
    default: return super.performKeyEquivalent(with: event)
    }
  }
  
  override func selectText(_ sender: Any?) {
    super.selectText(sender)
    currentEditor()?.selectedRange = NSRange(location: stringValue.count, length: 0)
  }

  override var mouseDownCanMoveWindow: Bool {
    return true
  }
  
  func autoComplete(cmd: String) {
    let tokens = stringValue.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    guard !tokens.isEmpty else { return }
    if tokens.count > 1 {
      stringValue = tokens[0...].joined(separator: " ") + " \(cmd) ".lowercased()
    } else {
      stringValue = "\(cmd) ".lowercased()
    }
    window?.makeFirstResponder(nil)
  }
}
