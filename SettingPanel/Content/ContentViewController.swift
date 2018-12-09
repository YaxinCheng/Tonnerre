//
//  ContentViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-10-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class ContentViewController: NSViewController {
  
  var items: [[SettingItem]] = []
  @IBOutlet weak var collectionView: NSCollectionView! {
    didSet {
      collectionView.collectionViewLayout = {
        let layout = NSCollectionViewFlowLayout()
        let difference: CGFloat = 300 // difference between collectionView from the whole view
        layout.sectionInset = NSEdgeInsets(top: 30, left: 20, bottom: 20, right: difference + 20)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 10
        layout.itemSize = NSSize(width: 370, height: 90)
        return layout
      }()
    }
  }
}

extension ContentViewController: ContentViewDelegate {
  func remove(cell: SettingCell) {
    guard let indexPath = cell.indexPath else { return }
    items[indexPath.section].remove(at: indexPath.item)
    collectionView.deleteItems(at: [indexPath])
    collectionView.reloadData()
  }
}

extension ContentViewController: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return items[section].count
  }
  
  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    return items.count
  }
  
  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let item = items[indexPath.section][indexPath.item]
    let cell = collectionView.makeItem(withIdentifier: item.displayIdentifier, for: indexPath) as! SettingCell
    cell.item = item
    cell.indexPath = indexPath
    cell.delegate = self
    return cell
  }
}
