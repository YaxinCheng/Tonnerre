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
  private static let shrinkRatio: CGFloat = 0.96
  private var originalSize: NSSize!
  private var shrinkedSize: NSSize {
    return NSSize(width: originalSize.width * SettingCell.shrinkRatio, height: originalSize.height * SettingCell.shrinkRatio)
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
    
    originalSize = view.frame.size
  }
  
  override func mouseDown(with event: NSEvent) {
    shrinkSize()
    super.mouseDown(with: event)
  }
  
  override func mouseUp(with event: NSEvent) {
    resetSize()
    super.mouseUp(with: event)
  }
  
  private var originalOrigin: NSPoint? = nil
  
  private func shrinkSize() {
    let targetSize = shrinkedSize
    originalOrigin = view.frame.origin
    NSAnimationContext.runAnimationGroup { [weak self] (context) in
      guard let origin = originalOrigin else { return }
      context.duration = 0.5
      let shrinkedOrigin = NSPoint(x: origin.x + targetSize.width * (1 - SettingCell.shrinkRatio)/2,
                                   y: origin.y + targetSize.height * (1 - SettingCell.shrinkRatio)/2)
      self?.view.animator().frame = NSRect(origin: shrinkedOrigin, size: targetSize)
      self?.view.animator().layer?.shadowRadius = 20
    }
  }
  
  private func resetSize() {
    guard let origin = originalOrigin else { return }
    let size = originalSize!
    NSAnimationContext.runAnimationGroup { [weak self] (context) in
      context.duration = 0.5
      self?.view.animator().frame = NSRect(origin: origin, size: size)
      self?.view.animator().layer?.shadowRadius = 10
    }
  }
}
