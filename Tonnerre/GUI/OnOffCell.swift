//
//  OnOffCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-15.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class OnOffCell: NSCollectionViewItem, DisplayableCellProtocol, ThemeProtocol {
  
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    theme = .currentTheme
  }
  
  var theme: TonnerreTheme {
    get {
      return .currentTheme
    } set {
      iconView.theme = newValue
      serviceLabel.textColor = newValue.imgColour
      introLabel.textColor = newValue.imgColour
    }
  }
  
}
