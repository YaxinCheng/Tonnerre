//
//  SettingCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-02.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class SettingCell: NSCollectionViewItem {
  
  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var contentLabel: NSTextField!
  var item: SettingItem! {
    didSet {
      item.configure(displayCell: self)
    }
  }
  var indexPath: IndexPath!
  weak var delegate: ContentViewDelegate?
  private var originalFrame: NSRect!
  private var shrinkedFrame: NSRect {
    let ratio: CGFloat = 0.96
    let shrinkedSize = NSSize(width: originalFrame.size.width * ratio, height: originalFrame.size.height * ratio)
    let movedX = originalFrame.size.width * (1 - ratio)/2
    let movedY = originalFrame.size.height * (1 - ratio)/2
    let movedOrigin  = NSPoint(x: originalFrame.origin.x + movedX, y: originalFrame.origin.y + movedY)
    return NSRect(origin: movedOrigin, size: shrinkedSize)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.wantsLayer = true
    view.layer?.cornerRadius = 15
    view.layer?.masksToBounds = true
    view.shadow = {
      let shadow = NSShadow()
      shadow.shadowBlurRadius = 10
      shadow.shadowColor = NSColor(named: "ShadowColor")
      shadow.shadowOffset = NSSize(width: 5, height: -10)
      return shadow
    }()
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    originalFrame = view.frame
  }
  
  override func mouseDown(with event: NSEvent) {
    shrinkSize()
    super.mouseDown(with: event)
  }
  
  override func mouseUp(with event: NSEvent) {
    resetSize()
    super.mouseUp(with: event)
  }
  
  private func shrinkSize() {
    let targetFrame = shrinkedFrame
    NSAnimationContext.runAnimationGroup { [weak self] (context) in
      context.duration = 0.7
      self?.view.animator().frame = targetFrame
    }
  }
  
  private func resetSize() {
    let targetFrame = originalFrame!
    NSAnimationContext.runAnimationGroup { [weak self] (context) in
      context.duration = 0.7
      self?.view.animator().frame = targetFrame
    }
  }
}
