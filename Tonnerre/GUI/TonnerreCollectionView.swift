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
  func serviceHighlighted(service: ServiceResult?)
  func retrieveLastQuery()
}

class TonnerreCollectionView: NSScrollView {
  private let cellHeight = 64
  private var highlightedItem: ServiceCell? // Actual index in the datasource array
  private var visibleIndex: Int = 0// Indicate where the highlight is, range from 0 to 8 (at most 9 options showing)
  var lastQuery: String = ""
  
  var highlightedItemIndex = -1 {
    didSet {
      if oldValue == highlightedItemIndex {
        visibleIndex = -1
        highlightedItem?.highlighted = false
        iconChange()
        return
      }
      let moveDown = highlightedItemIndex - oldValue >= 1
      let maxRows = 8
      let scrollPosition: NSCollectionView.ScrollPosition
      if visibleIndex == maxRows && moveDown { scrollPosition = .bottom }
      else if visibleIndex == 0 && !moveDown { scrollPosition = .top }
      else { scrollPosition = .init(rawValue: 0) }
      visibleIndex = min(maxRows, visibleIndex + 2 * moveDown.hashValue - 1)
      if highlightedItemIndex != 0 { visibleIndex = max(visibleIndex, 0) }
      if highlightedItemIndex >= 0 {
        collectionView.selectItem(at: IndexPath(item: highlightedItemIndex, section: 0), scrollPosition: scrollPosition)
      } else {
        iconChange()
        highlightedItem?.highlighted = false
        highlightedItem = nil
      }
    }
  }
  
  private func iconChange() {
    guard datasource.count > 0 else { return }
    if case .result(_, _) = datasource[0] {
      delegate?.serviceHighlighted(service: datasource[0])
    } else {
      delegate?.serviceHighlighted(service: nil)
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
        self?.highlightedItemIndex = -1
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
      guard actualIndex < datasource.count, case .result(let service, let value) = datasource[actualIndex] else { return }
      datasource = []
      delegate?.serve(with: service, target: value, withCmd: false)
    case 48:// Tab
      let highlightIndex = highlightedItemIndex >= 0 ? highlightedItemIndex : 0
      guard datasource.count > 0 else { return }
      delegate?.tabPressed(service: datasource[highlightIndex])
    case 49:
      highlightedItem?.preview()
    case 125, 126:// Up/down arrow
      if event.modifierFlags.contains(.command) {
        highlightedItemIndex = event.keyCode == 125 ? datasource.count - 1 : 0
      } else {
        let movement = NSDecimalNumber(decimal: pow(-1, (event.keyCode == 126).hashValue)).intValue// if key == 125, 1, else -1
        if datasource.count != 0 {
          if !(highlightedItemIndex == -1 && movement == -1) { highlightedItemIndex = highlightedItemIndex + movement }
        } else {
          delegate?.retrieveLastQuery()
        }
      }
    case 36, 76:// Enter
      let selectIndex = highlightedItemIndex >= 0 ? highlightedItemIndex : 0
      guard
        !datasource.isEmpty,
        case .result(let service, let value) = datasource[selectIndex]
      else { return }
      datasource = []
      delegate?.serve(with: service, target: value, withCmd: event.modifierFlags.contains(.command))
    default:
      break
    }
  }
  
  func modifierChanged(with event: NSEvent) {
    guard
      highlightedItemIndex < datasource.count,
      highlightedItemIndex >= 0,
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

extension TonnerreCollectionView: NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout {
  
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
    if case .result(_, let value) = data {
      cell.displayItem = value
      if let asyncedData = value as? AsyncedProtocol {
        asyncedData.asyncedViewSetup?(cell)
      }
    }
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
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    let width: CGFloat = 760
    return NSSize(width: width, height: 64)
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
