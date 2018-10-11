//
//  TonnerreCollectionView.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

/**
Delegate for TonnerreCollectionView
*/
protocol TonnerreCollectionViewDelegate: class {
  /**
  Service is selected with enter key or double click
  - parameter service: the service provider which provided the service
  - parameter target: the selected service
  - parameter withCmd: a flag indicates whether the cmd key is pressed with selection
  */
  func serve(with service: TonnerreService, target: DisplayProtocol, withCmd: Bool)
  /**
  Tab key is pressed, and request for auto completion
  - parameter service: the highlighted service that needs to be completed
  */
  func tabPressed(service: ServicePack)
  /**
  A service is selected and highlighted
  - parameter service: the service pack which is selected
  */
  func serviceHighlighted(service: ServicePack?)
  /**
  Request to fill in the placeholder field with given service
  - parameter service: the service highlighted and needs to be filled in the placeholder field
  */
  func fillPlaceholder(with service: ServicePack?)
  /**
  The cell is clicked. Request to focus on and deselect the textField
  */
  func viewIsClicked()
  /**
  Request to retrieve the last queried content
  */
  func retrieveLastQuery()
}

final class TonnerreCollectionView: NSScrollView {
  private let cellHeight: CGFloat = 56
  private weak var highlightedItem: ServiceCell?
  private var visibleIndex: Int = -1// Indicate where the highlight is, range from 0 to 8 (at most 9 options showing)
  private var mouseMonitor: Any? = nil
  
  private var highlightedItemIndex = -1 {// Actual index in the datasource array
    didSet {
      if oldValue == highlightedItemIndex {
        // When the highlighted is 0 or -1, and new datasource is added
        guard oldValue == -1 else { return }
        // If 0, make it -1
        visibleIndex = -1
        // Reset icons
        iconChange()
        if datasource.count > 0 {
          // If datasource exists, scroll to the top
          collectionView.scrollToItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)// Scroll to top
          delegate?.fillPlaceholder(with: datasource[0])
        }
        return
      }
      // Highlighted cursor moved 
      let moveDown = highlightedItemIndex - oldValue >= 1
      let maxRows = 8
      let scrollPosition: NSCollectionView.ScrollPosition
      // When the cursor is at the bottom or moved down more than 8 items
      if (visibleIndex == maxRows || highlightedItemIndex - oldValue > 8) && moveDown { scrollPosition = .bottom }
      // When the curosr is at the top or moved up more than 8 items
      else if (visibleIndex == 0 || oldValue - highlightedItemIndex > 8) && !moveDown { scrollPosition = .top }
      // Otherwise, do not scroll
      else { scrollPosition = .init(rawValue: 0) }
      // if move down, visibleIndex += 1, if move up, visibleIndex -= 1 
      visibleIndex = min(maxRows, visibleIndex + (moveDown ? 1 : -1))
      // if it is not move up from 0
      if !(oldValue == 0 && !moveDown) { visibleIndex = max(visibleIndex, 0) }
      if highlightedItemIndex >= 0 {
        delegate?.fillPlaceholder(with: datasource[highlightedItemIndex])
        collectionView.selectItem(at: IndexPath(item: highlightedItemIndex, section: 0), scrollPosition: scrollPosition)
      } else {
        iconChange()
        // highlightedIndex == -1 will remove the highlight cursor
        highlightedItem?.highlighted = false
        highlightedItem = nil
        guard let first = datasource.first else { return }
        // Fill the placeholder with the first item
        delegate?.fillPlaceholder(with: first)
      }
    }
  }
  
  private func iconChange() {
    guard datasource.count > 0 else { return }
    if case .service(_, _) = datasource[0] {
      delegate?.serviceHighlighted(service: datasource[0])
    } else {
      delegate?.serviceHighlighted(service: nil)
    }
  }
  
  @IBOutlet weak var collectionView: NSCollectionView! {
    didSet {
      // Accepts the scroll notification
      collectionView.postsBoundsChangedNotifications = true
    }
  }
   
  /**
  The autolayout constraint for collectionView's height
  - Warning: the actual constraint is defined in the Storyboard, and this is only a reference to it.
  */
  private weak var collectionViewHeight: NSLayoutConstraint! {
    return constraints.filter { $0.identifier == "collectionViewHeightConstraint" }.first!
  }
  
  weak var delegate: TonnerreCollectionViewDelegate?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    let centre = NotificationCenter.default
    centre.addObserver(self, selector: #selector(collectionViewDidScroll), name: NSView.boundsDidChangeNotification, object: collectionView)
    mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { [weak self] (event) -> NSEvent? in
      // Listen to the mouse click, and send the requests out
      self?.delegate?.viewIsClicked()
      return event
    }
    centre.addObserver(forName: .windowIsHiding, object: nil, queue: .main) { [weak self] _ in
      self?.datasource = []
    }
  }
  
  deinit {
    guard let monitor = mouseMonitor else { return }
    NSEvent.removeMonitor(monitor)
    mouseMonitor = nil
  }
  /**
   The objects that will be displayed on the collectionView
  */
  var datasource: [ServicePack] = [] {
    didSet {
      collectionViewHeight.constant = cellHeight * CGFloat(min(datasource.count, 9))
      collectionView.reloadData()
      guard !datasource.isEmpty else { return }
      DispatchQueue.main.async { [weak self] in
        // Move the highlighted index to -1. 
        // Warning: this will affect the placeholder field
        self?.highlightedItemIndex = -1
      }
    }
  }
  
  /**
   Reacts when different keys are pressed
   - parameter event: An event sent to this function when non-modifier keys are pressed
  */
  override func keyDown(with event: NSEvent) {
    highlightedItem?.popoverView.close()
    switch event.keyCode {
    case 18...23, 25, 26, 83...89, 91, 92:// ⌘ + number
      guard event.modifierFlags.contains(.command) else { return }
      let keyCodeMap: [UInt16: Int] = [18: 1, 19: 2, 20: 3, 21: 4, 23: 5, 22: 6, 26: 7, 28: 8, 25: 9,
                        83: 1, 84: 2, 85: 3, 86: 4, 87: 5, 88: 6, 89: 7, 91: 8, 92: 9]
      let selectedIndex = keyCodeMap[event.keyCode]! - 1
      let currentIndex = visibleIndex
      let actualIndex = selectedIndex - max(currentIndex, 0) + max(highlightedItemIndex, 0)
      guard actualIndex < datasource.count, case .service(let service, let value) = datasource[actualIndex] else { return }
      delegate?.serve(with: service, target: value, withCmd: false)
    case 48:// Tab
      let highlightIndex = highlightedItemIndex >= 0 ? highlightedItemIndex : 0
      guard datasource.count > 0 else { return }
      delegate?.tabPressed(service: datasource[highlightIndex])
    case 49:// Space
      highlightedItem?.preview()
    case 36, 76: // Enter keys
      guard event.modifierFlags.contains(.command), let (service, value) = enterPressed() else { break }
      delegate?.serve(with: service, target: value, withCmd: true)
    case 123, 124: break // Ignore left/right arrow
    case 125, 126:// Up/down arrow
      let movement = event.keyCode == 125 ? 1 : -1// if key == 125, 1, else -1
      if datasource.count == 0 && movement == -1 {
        delegate?.retrieveLastQuery()
      } else {
        highlightedItemIndex = min(max(highlightedItemIndex + movement, -1), datasource.count - 1)
      }
    default:
      highlightedItemIndex = -1
    }
  }
  
  /**
   Reacts when the enter key is pressed or released
   - returns: The selected service(DisplayProtocol) with its service provider(TonnerreService)
  */
  func enterPressed() -> (TonnerreService, DisplayProtocol)? {
    let selectIndex = max(highlightedItemIndex, 0)
    guard
      !datasource.isEmpty,
      case .service(let service, let value) = datasource[selectIndex]
      else { return nil }
    if !(service is TonnerreInstantService) { datasource = [] }
    return (service, value)
  }
  
  /**
   Reacts when the cmd key is pressed and released
   - parameter event: An event sent to this function when cmd key is pressed or released
  */
  func modifierChanged(with event: NSEvent) {
    guard highlightedItemIndex >= 0, highlightedItemIndex < datasource.count else { return }
    let source = datasource[highlightedItemIndex]
    if event.modifierFlags.contains(.command) {
      highlightedItem?.introLabel.stringValue = source.alterContent ?? source.content
      highlightedItem?.iconView.image = source.alterIcon ?? source.icon
    } else if event.modifierFlags.contains(.init(rawValue: 256)) {// Released key
      highlightedItem?.introLabel.stringValue = source.content
      highlightedItem?.iconView.image = source.icon
    }
  }
  
  /**
   Update the index indicator when collection view scrolls
  */
  @objc private func collectionViewDidScroll() {
    let visibleCells = getVisibleCells()
    for (index, cell) in visibleCells.enumerated() {
      cell.cmdLabel.stringValue = "⌘\(index + 1)"
    }
  }
  
  /**
   Manually return the visible (actual visible) cells' indeces
   - returns: An array of indeces in the datasource, whose object is visible on screen
  */
  func getVisibleIndexes() -> [Int] {
    let topIndex = highlightedItemIndex - visibleIndex
    return (0...8).map({ topIndex + $0 }).filter { $0 >= 0 && $0 < datasource.count }
  }
  
  /**
   Manually return the visible (actual visible) cells
   - returns: An array of datasource objects that are visible on screen
   */
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
    let origin = collectionView.makeItem(withIdentifier: .ServiceCell, for: indexPath)
    guard let cell = origin as? ServiceCell else { return origin }
    let data = datasource[indexPath.item]
    cell.iconView.image = data.icon
    cell.serviceLabel.stringValue = data.name
    cell.introLabel.stringValue = data.content
    cell.highlighted = false
    cell.cmdLabel.stringValue = "⌘\(indexPath.item % 9 + 1)"
    cell.delegate = self
    if case .service(_, let value) = data {
      cell.displayItem = value
      if let asyncedData = value as? AsyncDisplayable {
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
    if indexPath.item != highlightedItemIndex { highlightedItemIndex = indexPath.item }
    highlightedItem?.highlighted = false
    highlightedItem = cell
    highlightedItem?.highlighted = true
    delegate?.serviceHighlighted(service: datasource[indexPath.item])
  }
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    let width: CGFloat = 665
    return NSSize(width: width, height: cellHeight)
  }
}

private extension NSCollectionView {
  func selectItem(at indexPath: IndexPath, scrollPosition: NSCollectionView.ScrollPosition) {
    selectItems(at: [indexPath], scrollPosition: scrollPosition)
    delegate?.collectionView?(self, didSelectItemsAt: [indexPath])
  }
}

extension TonnerreCollectionView: ServiceCellDelegate {
  func cellDoubleClicked() {
    guard let (service, value) = enterPressed() else { return }
    delegate?.serve(with: service, target: value, withCmd: false)
  }
}
