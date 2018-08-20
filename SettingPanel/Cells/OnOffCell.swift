//
//  OnOffCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class OnOffCell: NSView, SettingCell {
  @IBOutlet weak var titleLabel: NSTextField!
  @IBOutlet weak var detailLabel: NSTextField!
  let type: SettingCellType = .onOff
  var settingKey: String!
  
  let toggle: Switch
  
  required init?(coder decoder: NSCoder) {
    toggle = {
      $0.animationSpeed = 3
      $0.animationProgress = 0
      return $0
    }(Switch(name: "Switch"))
    super.init(coder: decoder)
   
    toggle.delegate = self
    toggle.translatesAutoresizingMaskIntoConstraints = false
    translatesAutoresizingMaskIntoConstraints = false
    addSubview(toggle)
    NSLayoutConstraint.activate([
      toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
      toggle.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
      toggle.heightAnchor.constraint(equalToConstant: 50),
      toggle.widthAnchor.constraint(equalToConstant: 50)
    ])
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    NSLayoutConstraint.activate([toggle.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0)])
    let userDefault = UserDefaults.shared
    let state = userDefault.bool(forKey: settingKey)
    if state == false { toggle.state = .off }
    else { toggle.state = .on }
  }
}

extension OnOffCell: SwitchDelegate {
  func valueChanged(sender: Switch) {
    let userDefault = UserDefaults.shared
    userDefault.set(sender.state == .on, forKey: settingKey)
  }
}
