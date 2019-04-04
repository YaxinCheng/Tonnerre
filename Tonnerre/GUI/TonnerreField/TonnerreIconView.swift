//
//  TonnerreIconView.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TonnerreIconView: NSImageView {
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    NotificationCenter.default.addObserver(forName: .windowIsHiding, object: nil, queue: .main) { [weak self] _ in
      self?.image = #imageLiteral(resourceName: "tonnerre")
    }
  }
  
  private static let imagesTintWithTheme: Set<NSImage> = [#imageLiteral(resourceName: "tonnerre.icns"), #imageLiteral(resourceName: "tonnerre")]
  
  override func draw(_ dirtyRect: NSRect) {
    if image != nil && type(of: self).imagesTintWithTheme.contains(image!) {
      image = image?.tintedImage(with: .labelColor)
    }
    super.draw(dirtyRect)
  }
  
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
  
  override func mouseUp(with event: NSEvent) {
    guard event.clickCount == 2 else { return }
    guard
      let designedFrame = window?.frame,
      let mainScreen = NSScreen.main
    else { return }
    let x = mainScreen.frame.width/2 - designedFrame.width/2
    let y = mainScreen.frame.height * 5 / 6 - designedFrame.height
    window?.setFrameOrigin(NSPoint(x: x, y: y))
  }
}
