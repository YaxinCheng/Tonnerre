//
//  TonnerreCollectionView.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol TonnerreCollectionViewDelegate: class {
  func serve(with service: TonnerreService, target: Displayable, withCmd: Bool)
  func tabPressed(service: ServiceResult)
  func serviceHighlighted(service: ServiceResult)
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
    let centre = NotificationCenter.default
    centre.addObserver(self, selector: #selector(collectionViewDidScroll(notification:)), name: NSView.boundsDidChangeNotification, object: collectionView)
    centre.addObserver(forName: .windowIsHiding, object: nil, queue: .main) { [weak self] _ in
      self?.datasource = []
    }
  }
  
  var datasource: [ServiceResult] = [] {
    didSet {
      collectionViewHeight.constant = CGFloat(cellHeight * min(datasource.count, 9))
      collectionView.reloadData()
      if datasource.isEmpty { return }
      DispatchQueue.main.async { [weak self] in
        self?.highlightedItemIndex = 0
      }
    }
  }

  override func keyDown(with event: NSEvent) {
    switch event.keyCode {
    case 18...23, 25, 26, 83...89, 91, 92:// ⌘ + number
      guard event.modifierFlags.contains(.command) else { return }
      let keyCodeMap: [UInt16: Int] = [18: 1, 19: 2, 20: 3, 21: 4, 23: 5, 22: 6, 26: 7, 28: 8, 25: 9,
                        83: 1, 84: 2, 85: 3, 86: 4, 87: 5, 88: 6, 89: 7, 91: 8, 92: 9]
      let selectedIndex = keyCodeMap[event.keyCode]! - 1
      let currentIndex = visibleIndex
      let actualIndex = selectedIndex - currentIndex + highlightedItemIndex
      guard case .result(let service, let value) = datasource[actualIndex] else { return }
      datasource = []
      delegate?.serve(with: service, target: value, withCmd: false)
    case 48:// Tab
      delegate?.tabPressed(service: datasource[highlightedItemIndex])
    case 125, 126:// Up/down arrow
      let movement = NSDecimalNumber(decimal: pow(-1, (event.keyCode == 126).hashValue)).intValue// if key == 125, 1, else -1
      guard datasource.count != 0 else { return }
      highlightedItemIndex = (highlightedItemIndex + movement + datasource.count) % datasource.count
    case 36, 76:// Enter
      guard
        !datasource.isEmpty,
        case .result(let service, let value) = datasource[highlightedItemIndex]
      else { return }
      datasource = []
      delegate?.serve(with: service, target: value, withCmd: event.modifierFlags.contains(.command))
    case 53:
      (window as? BaseWindow)?.isHidden = true
    default:
      break
    }
  }
  
  func modifierChanged(with event: NSEvent) {
    guard
      highlightedItemIndex < datasource.count,
      case .result(let service, _) = datasource[highlightedItemIndex],
      let item = highlightedItem,
      let alterContent = service.alterContent
    else { return }
    if event.modifierFlags.contains(.command) {
      item.introLabel.stringValue = alterContent
      if service.alterIcon != nil {
        item.iconView.image = service.alterIcon
      }
    } else if event.modifierFlags.contains(.init(rawValue: 256)) {// Released key
      item.introLabel.stringValue = datasource[highlightedItemIndex].content
      if service.alterIcon != nil {
        item.iconView.image = service.icon
      }
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
