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
  
}
