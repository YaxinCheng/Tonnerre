//
//  TintedImageView.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-09.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class TintedImageView: NSImageView {
  override func draw(_ dirtyRect: NSRect) {
    image = image?.tintedImage(with: .labelColor)
    super.draw(dirtyRect)
  }
}
