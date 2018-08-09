//
//  ViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {

  @IBOutlet weak var contentView: NSView!
  @IBOutlet weak var tabBarView: NSStackView!
  private var currentTab: NSStoryboardSegue.Identifier = .secondTab
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    contentView.layer?.backgroundColor = NSColor.clear.cgColor
    performSegue(withIdentifier: .firstTab, sender: self)
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
    guard identifier != currentTab else { return false }
    currentTab = identifier
    return true
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    guard
      let identifier = segue.identifier,
      let destinationVC = segue.destinationController as? SettingViewController
    else { return }
    switch identifier {
    case .firstTab: destinationVC.settingOptions = ([.onOff], [.text])
    case .secondTab: destinationVC.settingOptions = ([], [.text])
    default: break
    }
  }
}

