//
//  ClipboardMonitor.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class ClipboardMonitor {
  private let pasteboard: NSPasteboard
  private var changedCount: Int
  private let `repeat`: Bool
  private let interval: TimeInterval
  private let callback: (NSAttributedString, NSPasteboard.PasteboardType)->Void
  private var timer: Timer?
  
  init(interval: TimeInterval, repeat: Bool = false, callback: @escaping (NSAttributedString, NSPasteboard.PasteboardType)->Void) {
    pasteboard = NSPasteboard.general
    changedCount = pasteboard.changeCount
    self.`repeat` = `repeat`
    self.interval = interval
    self.callback = callback
  }
  
  func start() {
    guard !(timer?.isValid ?? false) else { return }
    timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: `repeat`) { [weak self] _ in
      guard
        let changedCount = self?.pasteboard.changeCount,
        let originCount = self?.changedCount,
        originCount != changedCount
      else { return }
      if let fileURL = self?.pasteboard.string(forType: .fileURL) {
        self?.callback(NSAttributedString(string: fileURL), .fileURL)
      } else if let string = self?.pasteboard
        .readObjects(forClasses: [NSAttributedString.self])?
        .first as? NSAttributedString {
        self?.callback(string, .string)
      }
      self?.changedCount = changedCount
    }
    timer?.fire()
  }
  
  func stop() {
    guard timer?.isValid ?? false else { return }
    timer?.invalidate()
    timer = nil
  }
}
