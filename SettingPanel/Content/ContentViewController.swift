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
  @IBOutlet weak var collectionView: NSCollectionView!
  
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
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    let item = items[indexPath.section][indexPath.item]
    let defaultCellSize = NSSize(width: 360, height: 0)
    let nameSize = item.attributedName.boundingRect(with: defaultCellSize, options: [.usesFontLeading, .usesLineFragmentOrigin]).size
    let contentSize = item.attributedContent.boundingRect(with: defaultCellSize, options: [.usesFontLeading, .usesLineFragmentOrigin]).size
    let combinedHeight: CGFloat = 8 + nameSize.height + contentSize.height + 4 + 32 + 8
    return NSSize(width: 370, height: combinedHeight)
  }
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 20
  }
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
    let difference: CGFloat = 300 // difference between collectionView from the whole view
    return NSEdgeInsets(top: 30, left: 20, bottom: 20, right: difference + 20)
  }
}
