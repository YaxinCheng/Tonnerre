//
//  OnOffCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-15.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Lottie

final class OnOffCell: NSCollectionViewItem, CellProtocol {
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  private let toggleAnimation = LOTAnimationView(name: "toggle_switch")
  private let (onProgress, offProgress): (CGFloat, CGFloat) = (0.45, 0)
  var disabled: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    let height = view.bounds.height
    toggleAnimation.frame = CGRect(x: view.bounds.width - height * 2, y: -height/2, width: height * 2, height: height * 2)
    toggleAnimation.animationSpeed = 3
    view.addSubview(toggleAnimation)
  }
  
  override func viewWillAppear() {
    toggleAnimation.animationProgress = disabled ? offProgress : onProgress
    theme = .current
  }
  
  var theme: TonnerreTheme {
    get {
      return .current
    } set {
      serviceLabel.textColor = newValue.imgColour
      introLabel.textColor = newValue.imgColour
      let generateShadow: () -> NSShadow = {
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5)
        shadow.shadowBlurRadius = 1
        shadow.shadowOffset = NSSize(width: 2, height: 3)
        return shadow
      }
      switch newValue {
      case .dark:
        iconView.shadow = nil
        toggleAnimation.shadow = nil
      case .light:
        iconView.shadow = generateShadow()
        toggleAnimation.shadow = generateShadow()
      }
    }
  }
  
  func animate() {
    if disabled {
      toggleAnimation.play(fromProgress: onProgress, toProgress: offProgress, withCompletion: nil)
    } else {
      toggleAnimation.play(fromProgress: offProgress, toProgress: onProgress, withCompletion: nil)
    }
  }
}
