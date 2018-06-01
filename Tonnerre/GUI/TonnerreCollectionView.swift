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
  func tabPressed(service: Displayable)
}

class TonnerreCollectionView: NSScrollView {
  private let cellHeight = 64
  private var highlightedItem: ServiceCell?
  private var visibleIndex: Int = 0
  
  var highlightedItemIndex = 0 {
    didSet {
      let moveDown = (highlightedItemIndex - oldValue >= 1 && highlightedItemIndex - oldValue < 8) || (oldValue - highlightedItemIndex == datasource.count - 1)
      let maxRows = 8
      let oldVisibleIndex = visibleIndex
      if oldValue == 0 && !moveDown { visibleIndex = maxRows }
      else if oldValue == datasource.count - 1 && moveDown { visibleIndex = 0 }
      else { visibleIndex = moveDown ? min(visibleIndex + 1, maxRows) : max(visibleIndex - 1, 0) }
      let scrollPosition: NSCollectionView.ScrollPosition
      if oldVisibleIndex == 0 && !moveDown { scrollPosition = .top }
      else if oldVisibleIndex == 8 && moveDown { scrollPosition = .bottom }
      else { scrollPosition = .init(rawValue: 0) }
      collectionView.selectItem(at: IndexPath(item: highlightedItemIndex, section: 0), scrollPosition: scrollPosition)
    }
  }
  
  @IBOutlet weak var collectionView: NSCollectionView!
  var collectionViewHeight: NSLayoutConstraint!
  weak var delegate: TonnerreCollectionViewDelegate?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    collectionViewHeight = constraints.filter({ $0.identifier == "collectionViewHeightConstraint"}).first!
    NotificationCenter.default.addObserver(self, selector: #selector(collectionViewDidScroll(notification:)), name: NSView.boundsDidChangeNotification, object: collectionView)
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
    switch event.keyCode {
    case 18...25:// ⌘ + number
      guard event.modifierFlags.contains(.command) else { return }
      let selectedIndex = Int(event.keyCode) - 18
      let currentIndex = visibleIndex
      let actualIndex = selectedIndex - currentIndex + highlightedItemIndex
      guard let selectedService = datasource[actualIndex] as? URL else { return }
      datasource = []
      delegate?.openService(service: selectedService)
    case 48:// Tab
      delegate?.tabPressed(service: datasource[highlightedItemIndex])
    case 125, 126:// Up/down arrow
      if event.keyCode == 125 { highlightedItemIndex = (highlightedItemIndex + 1 + datasource.count) % datasource.count }
      else { highlightedItemIndex = (highlightedItemIndex - 1 + datasource.count) % datasource.count }
    case 36, 76:// Enter
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
    collectionView.postsBoundsChangedNotifications = true
  }
  
  @objc private func collectionViewDidScroll(notification: Notification) {
    let changingIndexes = (0...8).map({ $0 - visibleIndex + highlightedItemIndex }).filter({ $0 >= 0 && $0 < datasource.count })
    let indexPaths = changingIndexes.map({ IndexPath(item: $0, section: 0) })
    for (index, cell) in indexPaths.compactMap({ collectionView.item(at: $0) as? ServiceCell }).enumerated() {
      cell.cmdLabel.stringValue = "⌘\(index + 1)"
    }
//    collectionView.reloadItems(at: Set(indexPaths))
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
      let cell = collectionView.item(at: indexPath) as? ServiceCell
    else { return }
    highlightedItem?.highlighted = false
    highlightedItem = cell
    highlightedItem?.highlighted = true
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
    return item
  }
}
