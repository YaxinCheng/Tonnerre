//
//  SplitViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-02.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class SplitViewController: NSViewController {
  
  @IBOutlet weak var contentView: NSView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "providers":
      let destinationVC = segue.destinationController as! ContentViewController
      destinationVC.items = [[ProviderItem(key: ""), ProviderItem(key: "")]]
    default:
      break
    }
  }
}
