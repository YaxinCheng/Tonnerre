//
//  PreviewPopover.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class PreviewPopover: NSPopover, NSPopoverDelegate {
  private(set) static var shared = PreviewPopover()
  
  private override init() {
    super.init()
    self.contentSize = NSSize(width: 500, height: 700)
    self.behavior = .transient
    self.delegate = self
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func popoverDidClose(_ notification: Notification) {
    PreviewPopover.shared = PreviewPopover()
    contentViewController = nil
  }
}
