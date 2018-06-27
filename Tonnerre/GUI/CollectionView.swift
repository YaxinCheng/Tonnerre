//
//  CollectionView.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-27.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol CollectionViewDataSource: class {
  func collectionView(_ collectionView: CollectionView, heightForItemAt section: Int) -> CGFloat
}

class CollectionView: NSScrollView {
  private var registeredNibs: [NSUserInterfaceItemIdentifier: NSNib] = [:]
  private var registeredClses: [NSUserInterfaceItemIdentifier: CollectionViewCell.Type] = [:]
  private var cachedCells: [CollectionViewCell] = []
  weak var dataSource: CollectionViewDataSource?
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  
  /*
   MARK: - Register part
   */
  func register(nib: NSNib, withIdentifier identifier: NSUserInterfaceItemIdentifier) {
    registeredNibs[identifier] = nib
  }
  
  func register(class: CollectionViewCell.Type, withIdentifier identifier: NSUserInterfaceItemIdentifier) {
    registeredClses[identifier] = `class`
  }
  
  
  /*
   MARK: - populate part
   */
  private func buildView(fromNib nib: NSNib) -> CollectionViewCell? {
    var viewObjects: NSArray?
    guard nib.instantiate(withOwner: self, topLevelObjects: &viewObjects) else { return nil }
    for view in viewObjects ?? [] {
      if let firstView = view as? CollectionViewCell {
        return firstView
      }
    }
    return nil
  }
  
  func makeItem(withIdentifier identifier: NSUserInterfaceItemIdentifier, atIndexPath indexPath: IndexPath) -> CollectionViewCell {
    let cellHeight = dataSource?.collectionView(self, heightForItemAt: indexPath.section) ?? 100// 100 is the default height
    let documentHeight = documentView?.bounds.height ?? bounds.height
    let cellView: CollectionViewCell
    if cellHeight * CGFloat(indexPath.item) > documentHeight && !cachedCells.isEmpty {
      cellView = cachedCells.removeFirst()
    } else {
      if let targetNib = registeredNibs[identifier] {
        cellView = buildView(fromNib: targetNib)!
      } else if let `class` = registeredClses[identifier] {
        cellView = `class`.init()
      } else {
        fatalError("Unable to initialize cell from this identifier")
      }
    }
    cachedCells.append(cellView)
    let documentWidth = documentView?.bounds.width ?? bounds.width
    let yPos = documentHeight - cellHeight * CGFloat(indexPath.item + 1)
    cellView.frame = NSRect(x: 0, y: yPos, width: documentWidth, height: documentHeight)
    return cellView
  }
}
