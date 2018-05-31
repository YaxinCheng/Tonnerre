//
//  TonnerreCollectionView.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol TonnerreCollectionViewDelegate: class {
  func openService(service: URL)
}

class TonnerreCollectionView: NSScrollView {
  private let cellHeight = 64
  private var highlightedItem: ServiceCell?
  
  var highlightedItemIndex = 0 {
    didSet {
      highlightedItem = collectionView.highlightItem(at: IndexPath(item: highlightedItemIndex, section: 0))
    }
  }
  
  @IBOutlet weak var collectionView: NSCollectionView!
  var collectionViewHeight: NSLayoutConstraint!
  weak var delegate: TonnerreCollectionViewDelegate?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    collectionViewHeight = constraints.filter({ $0.identifier == "collectionViewHeightConstraint"}).first!
  }
  
  var datasource: [Displayable] = [] {
    didSet {
      collectionViewHeight.constant = CGFloat(cellHeight * min(datasource.count, 9))
      collectionView.reloadData()
      if datasource.isEmpty { return }
      DispatchQueue.main.async { [weak self] in
        self?.highlightedItem = self?.collectionView.highlightItem(at: IndexPath(item: self?.highlightedItemIndex ?? 0, section: 0))
      }
    }
  }
  
  override func keyDown(with event: NSEvent) {
    switch (event.keyCode, event.modifierFlags) {
    case let (code, modifier) where 18 <= code && code <= 25 && modifier.contains(.command):// ⌘ + number
      let selectedIndex = Int(event.keyCode) - 18
      guard selectedIndex <= collectionView.visibleItems().count else { return }
      let selectedItem = collectionView.visibleItems()[Int(event.keyCode) - 18]
      guard
        let indexPath = collectionView.indexPath(for: selectedItem),
        let selectedService = datasource[indexPath.item] as? URL
      else { return }
      datasource = []
      delegate?.openService(service: selectedService)
    case (125...126, _):// Up/down arrow
      becomeFirstResponder()
      highlightedItem?.highlighted = false
      if event.keyCode == 125 { highlightedItemIndex += 1 }
      else { highlightedItemIndex -= 1 }
      highlightedItemIndex = (highlightedItemIndex + datasource.count) % datasource.count // Down key, move down
    case (36, _):// Enter
      guard !datasource.isEmpty, let info = datasource[highlightedItemIndex] as? URL else { return }
      datasource = []
      delegate?.openService(service: info)
    default:
      break
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  
}

extension TonnerreCollectionView: NSCollectionViewDelegate, NSCollectionViewDataSource {
  
  func numberOfSections(in collectionView: NSCollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    return datasource.count
  }
  
  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ServiceCell"), for: indexPath) as? ServiceCell else {
      return ServiceCell(nibName: NSNib.Name("ServiceCell.xib"), bundle: Bundle.main)
    }
    let data = datasource[indexPath.item]
    cell.iconView.image = data.icon
    cell.serviceLabel.stringValue = data.name
    cell.introLabel.stringValue = data.content
    cell.highlighted = false
    cell.cmdLabel.stringValue = "⌘\(indexPath.item % 9 + 1)"
    return cell
  }
}

private extension NSCollectionView {
  func selectItem(at indexPath: IndexPath, scrollPosition: NSCollectionView.ScrollPosition) {
    selectItems(at: [indexPath], scrollPosition: scrollPosition)
    delegate?.collectionView?(self, didSelectItemsAt: [indexPath])
  }
  
  func highlightItem(at indexPath: IndexPath) -> ServiceCell? {
    guard
      let item = item(at: indexPath) as? ServiceCell
    else { return nil }
    item.highlighted = true
    scrollToItems(at: [indexPath], scrollPosition: .top)
    return item
  }
}
