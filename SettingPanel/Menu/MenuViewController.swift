//
//  MenuViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-10-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {
  
  @IBOutlet weak var collectionView: NSCollectionView! {
    didSet {
      collectionView.layer?.backgroundColor = .clear
    }
  }
  let options: [(String, NSImage)] = [
    ("Providers", #imageLiteral(resourceName: "settings"))
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    
  }
}

extension MenuViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return options.count
  }
  
  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let cell = collectionView.makeItem(withIdentifier: .menuOption, for: indexPath)
    guard let item = cell as? MenuOption else { return cell }
    let datasource = options[indexPath.item]
    item.textField?.stringValue = datasource.0
    item.imageView?.image = datasource.1
    return item
  }
}
