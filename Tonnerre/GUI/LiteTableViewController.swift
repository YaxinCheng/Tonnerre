//
//  LiteTableViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-18.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import LiteTableView

class LiteTableViewController: NSViewController {
  
  var datasource: ManagedList<ServicePack> = [] {
    didSet {
      completeViewReload()
      datasource.listExpanded = listExpanded
    }
  }
  var tableView: LiteTableView {
    return view as! LiteTableView
  }
  private var highlightedIndex = -1
  weak var delegate: LiteTableVCDelegate?
  
  let CellHeight: CGFloat = 56
  private var HeightConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    
    HeightConstraint = view.heightAnchor.constraint(equalToConstant: 0)
    NSLayoutConstraint.activate([HeightConstraint])
    
    NotificationCenter.default.addObserver(forName: .windowIsHiding, object: nil, queue: .main) { [weak self] _ in
      self?.datasource = []
    }
    
    tableView.liteDelegate   = self
    tableView.liteDataSource = self
    tableView.register(nib: NSNib(nibNamed: "ServiceCell", bundle: .main)!, withIdentifier: .ServiceCell)
    let allowedKeys: [UInt16] = [12, 48, 53, 36, 76, 49, 25, 26, 28, 91, 92] + Array(18...23) + Array(83...89)
    tableView.allowedKeyCodes.formUnion(allowedKeys)
  }
  
  private var modifierMonitor: Any?
  
  override func viewWillAppear() {
    super.viewWillAppear()
    
    modifierMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] in
      self?.modifierChanged($0)
      return $0
    }
  }
  
  override func viewWillDisappear() {
    super.viewWillDisappear()
    
    if let monitor = modifierMonitor {
      NSEvent.removeMonitor(monitor)
      modifierMonitor = nil
    }
  }
  
  func modifierChanged(_ event: NSEvent) {
    guard highlightedIndex >= 0, highlightedIndex < datasource.count else { return }
    let source = datasource[highlightedIndex]
    let highlightedCell = tableView.highlightedCell as? ServiceCell
    if event.modifierFlags.contains(.command) {
      highlightedCell?.introLabel.stringValue = source.alterContent ?? source.content
      highlightedCell?.iconView.image = source.alterIcon ?? source.icon
    } else if event.modifierFlags.contains(.init(rawValue: 256)) {// Released key
      highlightedCell?.introLabel.stringValue = source.content
      highlightedCell?.iconView.image = source.icon
    }
  }
  
  func retrieveHighlighted() -> ServicePack? {
    guard datasource.count > 0 else { return nil }
    return datasource[max(0, highlightedIndex)]
  }
  
  private func completeViewReload() {
    highlightedIndex = -1
    tableView.reload()
    if case .service(_, _)? = datasource.first {
      delegate?.serviceHighlighted(service: datasource.first)
    } else {
      delegate?.serviceHighlighted(service: nil)
    }
    delegate?.updatePlaceholder(service: datasource.first)
  }
  
  private func listExpanded(fromIndex index: Int) {
    guard index < 9 else { return }
    DispatchQueue.main.async { [weak self] in
      self?.completeViewReload()
    }
  }
}

extension LiteTableViewController: LiteTableDelegate, LiteTableDataSource {
  func viewDidScroll(_ tableView: LiteTableView) {
    for (index, cell) in tableView.visibleCells.enumerated() {
      (cell as? ServiceCell)?.cmdLabel.stringValue = "⌘\(index + 1)"
    }
  }
  
  func keyPressed(_ event: NSEvent) {
    switch event.keyCode {
    case 125, 126: // move down/up
      PreviewPopover.shared.close()
      if datasource.count == 0 && event.keyCode == 126 {
        delegate?.retrieveLastQuery()
      }
      guard datasource.count > 0 else { return }
      highlightedIndex += event.keyCode == 125 ? 1 : -1
      highlightedIndex = min(max(highlightedIndex, -1), datasource.count - 1)
      let selectedService = datasource[max(highlightedIndex, 0)]
      delegate?.serviceHighlighted(service: selectedService)
      delegate?.updatePlaceholder(service: selectedService)
    case 48: // tab
      guard datasource.count > 0 else { return }
      let selectedService = datasource[max(highlightedIndex, 0)]
      delegate?.tabPressed(service: selectedService)
    case 36, 76: // enter
      let withCmd = event.modifierFlags.contains(.command)
      guard
        withCmd || PreviewPopover.shared.isShown == true ,
        let servicePack = retrieveHighlighted()
      else { break }
      delegate?.serve(servicePack, withCmd: withCmd)
    case 49: // space
      (tableView.highlightedCell as? ServiceCell)?.preview()
    case 53:
      if PreviewPopover.shared.isShown == true {
        PreviewPopover.shared.close()
      } else {
        (tableView.window as? BaseWindow)?.isHidden = true
      }
    case 18...23, 25, 26, 28, 83...89, 91, 92:// ⌘ + number
      guard event.modifierFlags.contains(.command) else { return }
      let keyCodeMap: [UInt16: Int] = [18: 1, 19: 2, 20: 3, 21: 4, 23: 5, 22: 6, 26: 7, 28: 8, 25: 9,
                                       83: 1, 84: 2, 85: 3, 86: 4, 87: 5, 88: 6, 89: 7, 91: 8, 92: 9]
      let selectedIndex = keyCodeMap[event.keyCode]! - 1
      guard
        selectedIndex < tableView.visibleCells.count,
        let cell = tableView.visibleCells[selectedIndex] as? ServiceCell,
        let servicePack = cell.displayItem
      else { return }
      delegate?.serve(servicePack, withCmd: false)
    case 12: // Q
      guard event.modifierFlags.contains(.command) else { return }
      if type(of: self).canExit { // Double clicked cmd + Q
        #if DEBUG
        print("Double click trigered (\(String.CMD) + Q)")
        #else
        exit(0)
        #endif
      } else {
        delegate?.updatePlaceholder(string: " Double click \(String.CMD) + Q to exit")
        type(of: self).canExit = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
          self?.delegate?.updatePlaceholder(string: nil)
          LiteTableViewController.canExit = false
        }
      }
    default:
      break
    }
  }
  
  func cellReuseThreshold(_ tableView: LiteTableView) -> Int {
    return 9
  }
  
  func numberOfCells(_ tableView: LiteTableView) -> Int {
    HeightConstraint.constant = CellHeight * CGFloat(min(9, datasource.count))
    return datasource.count
  }
  
  func cellHeight(_ tableView: LiteTableView) -> CGFloat {
    return CellHeight
  }
  
  func prepareCell(_ tableView: LiteTableView, at index: Int) -> LiteTableCell {
    let cell = tableView.dequeueCell(withIdentifier: .ServiceCell) as! ServiceCell
    let data = datasource[index]
    cell.iconView.image = data.icon
    cell.serviceLabel.stringValue = data.name
    cell.introLabel.stringValue = data.content
    cell.cmdLabel.stringValue = "⌘\(index % 9 + 1)"
    cell.displayItem = data
    if case .service(_, let value) = data {
      if let asyncedData = value as? AsyncDisplayable {
        asyncedData.asyncUpdate?(cell)
      }
    }
    return cell
  }
}

fileprivate extension LiteTableViewController {
  static var canExit: Bool = false
}
