//
//  TonnerreField.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TonnerreField: NSTextField {
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    NotificationCenter.default.addObserver(forName: .windowIsHiding, object: nil, queue: .main) { [weak self] _ in
      self?.stringValue = ""
    }
  }
  
  override func performKeyEquivalent(with event: NSEvent) -> Bool {
    switch event.keyCode {
      // mute the sound for the several keys
    case 18...25, 36, 49, 53, 76, 125, 126: return true
    default: return super.performKeyEquivalent(with: event)
    }
  }
  
  override func selectText(_ sender: Any?) {
    super.selectText(sender)
    // Disable text select and keep editing possible
    currentEditor()?.selectedRange = NSRange(location: stringValue.count, length: 0)
  }
}
