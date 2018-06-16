//
//  OnOffCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-15.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Lottie

class OnOffCell: NSCollectionViewItem, DisplayableCellProtocol, ThemeProtocol {
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  private let toggleAnimation = LOTAnimationView(name: "toggle_switch")
  private let (onProgress, offProgress): (CGFloat, CGFloat) = (0.45, 0)
  var disabled: Bool = true {
    didSet {
      if disabled {
        toggleAnimation.play(fromProgress: onProgress, toProgress: offProgress, withCompletion: nil)
      } else {
        toggleAnimation.play(fromProgress: offProgress, toProgress: onProgress, withCompletion: nil)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    theme = .currentTheme
    let height = view.bounds.height
    toggleAnimation.frame = CGRect(x: view.bounds.width - height * 2, y: -height/2, width: height * 2, height: height * 2)
    toggleAnimation.animationSpeed = 1.5
    view.addSubview(toggleAnimation)
  }
  
  override func viewWillAppear() {
    toggleAnimation.animationProgress = disabled ? offProgress : onProgress
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
