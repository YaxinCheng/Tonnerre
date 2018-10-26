//
//  MenuViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-10-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {
  
  @IBOutlet weak var menuStack: NSStackView!
  weak var selectedButton: NSButton? = nil {
    willSet {
      selectedButton?.layer?.backgroundColor = .clear
    } didSet {
      selectedButton?.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    let categories = [("Service Providers", #imageLiteral(resourceName: "settings")), ("More", #imageLiteral(resourceName: "more"))]
    for option in categories {
      let button = buildingButtons(withOption: option)
      menuStack.addView(button, in: .top)
      NSLayoutConstraint.activate([
        button.widthAnchor.constraint(equalTo: menuStack.widthAnchor, multiplier: 1)
      ])
    }
  }
  
  @objc func buttonPressed(_ sender: NSButton) {
    selectedButton = sender
  }
  
  private func buildingButtons(withOption option: (String, NSImage)) -> NSButton {
    option.1.size = NSSize(width: 35, height: 35)
    let button = NSButton(title: option.0, image: option.1.tintedImage(with: .labelColor), target: self, action: #selector(buttonPressed(_:)))
    button.isBordered = false
    button.font = .systemFont(ofSize: 20)
    button.bezelStyle = .roundRect
    button.alignment = .left
    button.imageScaling = .scaleProportionallyDown
    button.imagePosition = .imageLeading
    button.imageHugsTitle = true
    button.focusRingType = .none
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }
}
