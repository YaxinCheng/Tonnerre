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
    guard
      let destinationVC = segue.destinationController as? ContentViewController,
      let identifier = segue.identifier,
      let menuOptionId = sender as? MenuOptionId,
      case .providers = identifier
    else {
      super.prepare(for: segue, sender: sender)
      return
    }
    setup(destinationVC: destinationVC, withOption: menuOptionId)
  }
  
  private func setup(destinationVC: ContentViewController, withOption option: MenuOptionId) {
    switch option {
    case .general:
      destinationVC.items = []
    case .providers:
      let builtinProviderFetcher = BuiltinProviderFetcher()
      let tneProviderFetcher = TNEProviderFetcher()
      destinationVC.items = [builtinProviderFetcher.fetch(), tneProviderFetcher.fetch()]
    }
  }
}
