//
//  ServiceCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class ServiceCell: NSCollectionViewItem, ThemeProtocol {
  
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var cmdLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    theme = .currentTheme
  }
  
  var highlighted: Bool = false {
    didSet {
      DispatchQueue.main.async { [weak self] in
        if self?.highlighted ?? false {
          self?.view.layer?.backgroundColor = NSColor(calibratedRed: 99/255, green: 147/255, blue: 1, alpha: 0.6).cgColor
        } else {
          self?.view.layer?.backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0).cgColor
        }
      }
    }
  }
  
  var theme: TonnerreTheme {
    get {
      return .currentTheme
    } set {
      iconView.theme = newValue
      serviceLabel.textColor = newValue.imgColour
      cmdLabel.textColor = newValue.imgColour
      introLabel.textColor = newValue.imgColour
    }
  }
}
