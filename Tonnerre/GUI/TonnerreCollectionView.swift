//
//  TonnerreCollectionView.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol TonnerreCollectionViewDelegate: class {
  func openService(service: URL, inFinder: Bool)
  func tabPressed(service: Displayable)
  func serviceHighlighted(service: Displayable)
}

class TonnerreCollectionView: NSScrollView {
  private let cellHeight = 64
  private var highlightedItem: ServiceCell? // Actual index in the datasource array
  private var visibleIndex: Int = 0// Indicate where the highlight is, range from 0 to 8 (at most 9 options showing)
  
  var highlightedItemIndex = 0 {
    didSet {
      if oldValue == highlightedItemIndex {
        visibleIndex = 0
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), scrollPosition: .top)
        return
      }
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
      DispatchQueue.main.async { [unowned self] in
        self.highlightedItemIndex = 0
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
      delegate?.openService(service: selectedService, inFinder: false)
    case 48:// Tab
      delegate?.tabPressed(service: datasource[highlightedItemIndex])
    case 125, 126:// Up/down arrow
      let movement = NSDecimalNumber(decimal: pow(-1, (event.keyCode == 126).hashValue)).intValue// if key == 125, 1, else -1
      highlightedItemIndex = (highlightedItemIndex + movement + datasource.count) % datasource.count
    case 36, 76:// Enter
      guard !datasource.isEmpty, let info = datasource[highlightedItemIndex] as? URL else { return }
      datasource = []
      delegate?.openService(service: info, inFinder: event.modifierFlags.contains(.command))
    default:
      break
    }
  }
  
  func modifierChanged(with event: NSEvent) {
    guard highlightedItemIndex < datasource.count, datasource[highlightedItemIndex] is URL, let item = highlightedItem else { return }
    if event.modifierFlags.contains(.command) {
      item.introLabel.stringValue = "Open in Finder"
    } else if event.modifierFlags.contains(.init(rawValue: 256)) {
      item.introLabel.stringValue = datasource[highlightedItemIndex].content
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
    collectionView.postsBoundsChangedNotifications = true
  }
  
  @objc private func collectionViewDidScroll(notification: Notification) {
    let visibleCells = getVisibleCells()
    for (index, cell) in visibleCells.enumerated() {
      cell.cmdLabel.stringValue = "⌘\(index + 1)"
    }
  }
  
  func getVisibleIndexes() -> [Int] {
    let topIndex = highlightedItemIndex - visibleIndex
    return (0...8).map({ topIndex + $0 }).filter { $0 >= 0 && $0 < datasource.count }
  }
  
  func getVisibleCells() -> [ServiceCell] {
    let visibleIndexes = getVisibleIndexes()
    let indexPaths = visibleIndexes.map { IndexPath(item: $0, section: 0) }
    return indexPaths.compactMap { collectionView.item(at: $0) as? ServiceCell }
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
    delegate?.serviceHighlighted(service: datasource[indexPath.item])
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
