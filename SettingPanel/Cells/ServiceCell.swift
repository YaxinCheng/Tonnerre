//
//  ServiceCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-12.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class ServiceCell: NSView, SettingCell {
  let type: SettingCellType = .gradient
  @IBOutlet weak var detailLabel: NSTextField!
  @IBOutlet weak var titleLabel: NSTextField!
  var settingKey: String!
  private let cellColour: GradientColours.Gradient
  var disabled: Bool {
    set {
      let userDefault = UserDefaults.shared
      userDefault.set(newValue, forKey: settingKey)
      setNeedsDisplay(bounds)
    } get {
      let userDefault = UserDefaults.shared
      return userDefault.bool(forKey: settingKey)
    }
  }
  
  required init?(coder decoder: NSCoder) {
    let gradientGenerator = GradientColours()
    cellColour = gradientGenerator.generate()
    
    super.init(coder: decoder)
  }
  
  override func draw(_ dirtyRect: NSRect) {
    let drawingColour = disabled ? GradientColours.disabled : cellColour
    let gradient = NSGradient(starting: drawingColour.begin, ending: drawingColour.end)
    gradient?.draw(in: dirtyRect, angle: 180)
    wantsLayer = true
    layer?.cornerRadius = 25
    layer?.masksToBounds = true
    super.draw(dirtyRect)
  }
  
  override func mouseUp(with event: NSEvent) {
    disabled = !disabled
  }
}
