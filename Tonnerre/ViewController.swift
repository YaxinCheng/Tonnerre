//
//  ViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  let indexManager = CoreIndexing()
  
  @IBOutlet weak var backgroundView: NSVisualEffectView!
  @IBOutlet weak var iconView: NSImageView!
  @IBOutlet weak var textField: TonnerreField!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    if let _ = UserDefaults.standard.value(forKey: StoredKeys.AppleInterfaceStyle.rawValue) as? String {
      iconView.image = #imageLiteral(resourceName: "tonnerre-light")
      textField.placeholderColour = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.4)
      backgroundView.material = .dark
    } else {
      iconView.image = #imageLiteral(resourceName: "tonnerre")
      textField.placeholderColour = NSColor(calibratedRed: 61/255, green: 61/255, blue: 61/255, alpha: 0.4)
      backgroundView.material = .light
    }
  }
  
  override func viewDidAppear() {
    indexManager.check()
  }
  
  override func viewDidDisappear() {
    
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
}

