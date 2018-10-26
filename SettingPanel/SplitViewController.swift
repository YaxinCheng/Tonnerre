//
//  SplitViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-10-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
  
  @IBOutlet weak var menuViewController: NSSplitViewItem!
  @IBOutlet weak var contentViewController: NSSplitViewItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
}
