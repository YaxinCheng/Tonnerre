//
//  TonnerreCollectionView.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol TonnerreCollectionViewDelegate: class {
  func serviceDidSelect(service: TonnerreService)
  func keyDidPress(keyEvent: NSEvent)
}

class TonnerreCollectionView: NSScrollView {
  private let cellHeight = 64
  private var keyboardMonitor: Any?
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
    delegate?.keyDidPress(keyEvent: event)
    switch (event.keyCode, event.modifierFlags) {
    case (125, _):
      highlightedItem?.highlighted = false
      highlightedItemIndex = (highlightedItemIndex + 1 + datasource.count) % datasource.count // Down key, move down
    case (126, _):
      highlightedItem?.highlighted = false
      highlightedItemIndex = (highlightedItemIndex - 1 + datasource.count) % datasource.count // Up key, move up
    default:
      break
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
    if keyboardMonitor == nil {
      keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] in
        self?.keyDown(with: $0)
        return $0
      }
    }
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
  
  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard
      let indexPath = indexPaths.first,
      let service = datasource[indexPath.item] as? TonnerreService
    else { return }
    delegate?.serviceDidSelect(service: service)
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
