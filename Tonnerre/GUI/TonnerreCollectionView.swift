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
  func viewIsClicked()
  func retrieveLastQuery()
}

class TonnerreCollectionView: NSScrollView {
  private let cellHeight = 56
  private weak var highlightedItem: DisplayableCellProtocol? // Actual index in the datasource array
  private var visibleIndex: Int = -1// Indicate where the highlight is, range from 0 to 8 (at most 9 options showing)
  var lastQuery: String = ""
  private var mouseMonitor: Any? = nil
  
  private var highlightedItemIndex = -1 {
    didSet {
      if oldValue == highlightedItemIndex {
        visibleIndex = -1
        if oldValue == -1 { iconChange() }
        return
      }
      let moveDown = highlightedItemIndex - oldValue >= 1
      let maxRows = 8
      let scrollPosition: NSCollectionView.ScrollPosition
      if (visibleIndex == maxRows || highlightedItemIndex - oldValue > 8) && moveDown { scrollPosition = .bottom }
      else if (visibleIndex == 0 || oldValue - highlightedItemIndex > 8) && !moveDown { scrollPosition = .top }
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
    centre.addObserver(self, selector: #selector(collectionViewDidScroll), name: NSView.boundsDidChangeNotification, object: collectionView)
    mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { [weak self] (event) -> NSEvent? in
      self?.delegate?.viewIsClicked()
      return event
    }
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
    (highlightedItem as? ServiceCell)?.popoverView.close()
    switch event.keyCode {
    case 18...23, 25, 26, 83...89, 91, 92:// ⌘ + number
      guard event.modifierFlags.contains(.command) else { return }
      let keyCodeMap: [UInt16: Int] = [18: 1, 19: 2, 20: 3, 21: 4, 23: 5, 22: 6, 26: 7, 28: 8, 25: 9,
                        83: 1, 84: 2, 85: 3, 86: 4, 87: 5, 88: 6, 89: 7, 91: 8, 92: 9]
      let selectedIndex = keyCodeMap[event.keyCode]! - 1
      let currentIndex = visibleIndex
      let actualIndex = selectedIndex - max(currentIndex, 0) + max(highlightedItemIndex, 0)
      guard actualIndex < datasource.count, case .result(let service, let value) = datasource[actualIndex] else { return }
      delegate?.serve(with: service, target: value, withCmd: false)
      guard let cell = collectionView.item(at: actualIndex) as? OnOffCell else { datasource = []; return }
      cell.disabled = !cell.disabled
      cell.animate()
    case 48:// Tab
      let highlightIndex = highlightedItemIndex >= 0 ? highlightedItemIndex : 0
      guard datasource.count > 0 else { return }
      delegate?.tabPressed(service: datasource[highlightIndex])
    case 49:
      (highlightedItem as? ServiceCell)?.preview()
    case 36, 76: // Enter keys
      guard event.modifierFlags.contains(.command), let (service, value) = enterPressed() else { break }
      delegate?.serve(with: service, target: value, withCmd: true)
    case 123, 124: break // Ignore left/right arrow
    case 125, 126:// Up/down arrow
      if event.modifierFlags.contains(.command) {
        visibleIndex = event.keyCode == 125 ? 7 : 1
        highlightedItemIndex = event.keyCode == 125 ? datasource.count - 1 : 0
      } else {
        let movement = NSDecimalNumber(decimal: pow(-1, (event.keyCode == 126).hashValue)).intValue// if key == 125, 1, else -1
        if datasource.count != 0 {
          highlightedItemIndex = min(max(highlightedItemIndex + movement, -1), datasource.count - 1)
        } else {
          delegate?.retrieveLastQuery()
        }
      }
    default:
      highlightedItemIndex = -1
    }
  }
  
  func enterPressed() -> (TonnerreService, Displayable)? {
    let selectIndex = max(highlightedItemIndex, 0)
    guard
      !datasource.isEmpty,
      case .result(let service, let value) = datasource[selectIndex]
      else { return nil }
    if let onoffCell = highlightedItem as? OnOffCell {
      onoffCell.disabled = !onoffCell.disabled
      onoffCell.animate()
    }
    else { datasource = [] }
    return (service, value)
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
  
  @objc private func collectionViewDidScroll() {
    let visibleCells = getVisibleCells()
    for (index, cell) in (visibleCells as? [ServiceCell] ?? []).enumerated() {
      cell.cmdLabel.stringValue = "⌘\(index + 1)"
    }
  }
  
  func getVisibleIndexes() -> [Int] {
    let topIndex = highlightedItemIndex - visibleIndex
    return (0...8).map({ topIndex + $0 }).filter { $0 >= 0 && $0 < datasource.count }
  }
  
  func getVisibleCells() -> [DisplayableCellProtocol] {
    let visibleIndexes = getVisibleIndexes()
    let indexPaths = visibleIndexes.map { IndexPath(item: $0, section: 0) }
    return indexPaths.compactMap { collectionView.item(at: $0) as? DisplayableCellProtocol }
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
    let data = datasource[indexPath.item]
    let identifier: String
    if case .result(let service, _) = data {
       identifier = service is ServicesService ? "OnOffCell" : "ServiceCell"
    } else { identifier = "ServiceCell" }
    let origin = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: identifier), for: indexPath)
    guard let cell = origin as? DisplayableCellProtocol else { return origin }
    cell.iconView.image = data.icon
    cell.serviceLabel.stringValue = data.name
    cell.introLabel.stringValue = data.content
    cell.highlighted = false
    if let servicecell = cell as? ServiceCell {
      servicecell.cmdLabel.stringValue = "⌘\(indexPath.item % 9 + 1)"
      if case .result(_, let value) = data {
        servicecell.displayItem = value
        if let asyncedData = value as? AsyncedProtocol {
          asyncedData.asyncedViewSetup?(servicecell)
        }
      }
    } else if let onOffCell = cell as? OnOffCell, case .result(_, let value) = data {
      onOffCell.disabled = (value as? TonnerreExtendService)?.isDisabled ?? type(of: (value as! TonnerreService)).isDisabled
    }
    return cell as! NSCollectionViewItem
  }
  
  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard
      let indexPath = indexPaths.first,
      let cell = collectionView.item(at: indexPath) as? DisplayableCellProtocol
    else { return }
    if indexPath.item != highlightedItemIndex { highlightedItemIndex = indexPath.item }
    highlightedItem?.highlighted = false
    highlightedItem = cell
    highlightedItem?.highlighted = true
    delegate?.serviceHighlighted(service: datasource[indexPath.item])
  }
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    let width: CGFloat = 700
    return NSSize(width: width, height: CGFloat(cellHeight))
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
