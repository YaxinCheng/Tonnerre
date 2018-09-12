//
//  ServiceCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-12.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class GradientCell: NSView, SettingCell {
  let type: SettingCellType = .gradient
  @IBOutlet weak var detailLabel: NSTextField!
  @IBOutlet weak var titleLabel: NSTextField!
  var settingKey: String!
  var url: URL? {
    didSet {
      menu = NSMenu(title: "")
      menu?.addItem(.init(title: "Remove", action: #selector(removeItem(_:)), keyEquivalent: ""))
    }
  }
  weak var viewController: SettingViewController?
  
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
  
  @objc private func removeItem(_ sender: Any) {
    guard let fileURL = url else { return }
    do {
      try FileManager.default.removeItem(at: fileURL)
      viewController?.remove(cell: self)
    } catch {
      
    }
  }
}
