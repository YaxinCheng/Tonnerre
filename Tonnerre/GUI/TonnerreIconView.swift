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
  
  private static let imagesWithTheme: Set<NSImage> = [#imageLiteral(resourceName: "tonnerre_extension"), #imageLiteral(resourceName: "tonnerre.icns"), #imageLiteral(resourceName: "tonnerre"), #imageLiteral(resourceName: "close"), #imageLiteral(resourceName: "eject"), #imageLiteral(resourceName: "settings"), #imageLiteral(resourceName: "clipboard")]
  
  override func draw(_ dirtyRect: NSRect) {
    if image != nil && type(of: self).imagesWithTheme.contains(image!) {
      image = image?.tintedImage(with: .labelColor)
    }
    super.draw(dirtyRect)
  }
  
  override var mouseDownCanMoveWindow: Bool {
    return true
  }
  
  override func mouseUp(with event: NSEvent) {
    guard event.clickCount == 2 else { return }
    let mouseLocation = NSEvent.mouseLocation
    guard
      var designedFrame = window?.frame,
      let mainScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
    else { return }
    designedFrame.origin.x = mainScreen.frame.width/2 - designedFrame.width/2
    designedFrame.origin.y = mainScreen.frame.height * 5 / 6 - designedFrame.height
    window?.setFrame(designedFrame, display: true)
  }
}
