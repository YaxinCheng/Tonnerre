//
//  MenuViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-10-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {
  
  @IBOutlet weak var collectionView: NSCollectionView!
  private var selectedItem: NSCollectionViewItem? {
    willSet {
      selectedItem?.highlightState = .forDeselection
    } didSet {
      selectedItem?.highlightState = .forSelection
    }
  }
  
  let options: [(name: String, icon: NSImage, id: MenuOptionId)] = [
    ("General Setting", #imageLiteral(resourceName: "tonnerre"), .general),
    ("Providers Setting", #imageLiteral(resourceName: "settings"), .providers)
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
  
  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard
      let firstSelect = indexPaths.first,
      let selectedItem = collectionView.item(at: firstSelect)
    else { return }
    self.selectedItem = selectedItem
    let option = options[firstSelect.item]
    parent?.performSegue(withIdentifier: .providers, sender: option.id)
  }
}
