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
    theme = TonnerreTheme.currentTheme
  }
  
  var theme: TonnerreTheme {
    get {
      return TonnerreTheme.currentTheme
    } set {
      iconView.theme = newValue
      serviceLabel.textColor = newValue.imgColour
      cmdLabel.textColor = newValue.imgColour
      introLabel.textColor = newValue.imgColour
    }
  }
}
