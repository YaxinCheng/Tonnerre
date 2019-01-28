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
  
  var datasource: TaggedList<ServicePack> = [] {
    didSet {
      completeViewReload()
      datasource.delegate = self
    }
  }
  weak var tableView: LiteTableView! {
    return view as? LiteTableView
  }
  private var highlightedIndex = -1
  weak var delegate: LiteTableVCDelegate?
  
  let CellHeight: CGFloat = 56
  private var HeightConstraint: NSLayoutConstraint!
  
  private var cmdQDoubleClick = MultiClickDetector(keyCode: 12, modifiers: .command, numberOfClicks: 2)
  
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
    
    cmdQDoubleClick.setFailedCallback { [weak self] in
        self?.delegate?.updatePlaceholder(string: nil)
    }
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
  
  /// Reset the LiteTableView as newly loaded
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
}

extension LiteTableViewController: TaggedListDelegate {
  func listDidChange(from index: Int) {
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
      upDownKeyPressed(withKeyCode: event.keyCode)
    case 48: // tab
      tabPressed()
    case 36, 76: // enter
      enterPressed(withEvent: event)
    case 49: // space
      (tableView.highlightedCell as? ServiceCell)?.preview()
    case 53: // ESC
      guard event.modifierFlags.rawValue == 256 else { return }
      escPrssed()
    case 18...23, 25, 26, 28, 83...89, 91, 92:// ⌘ + number
      guard event.modifierFlags.contains(.command) else { return }
      quickSelect(withKeyCode: event.keyCode)
    case 12: // Q
      guard event.modifierFlags.contains(.command) else { return }
      terminateProgramProcess(event)
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
    reset(cell: cell, dataIndex: index)
    return cell
  }
}

// MARK: - Keyboard events come here
extension LiteTableViewController {
  private func upDownKeyPressed(withKeyCode keyCode: UInt16) {
    PreviewPopover.shared.close()
    if datasource.count == 0 && keyCode == 126 {
      delegate?.retrieveLastQuery()
    }
    guard datasource.count > 0 else { return }
    if let cell = tableView.highlightedCell as? ServiceCell {
      reset(cell: cell, dataIndex: highlightedIndex)
    }
    highlightedIndex += keyCode == 125 ? 1 : -1
    highlightedIndex = min(max(highlightedIndex, -1), datasource.count - 1)
    let selectedService = datasource[max(highlightedIndex, 0)]
    delegate?.serviceHighlighted(service: selectedService)
    delegate?.updatePlaceholder(service: selectedService)
  }

  private func reset(cell: ServiceCell, dataIndex: Int) {
    let data = datasource[dataIndex]
    cell.iconView.image = data.icon
    cell.serviceLabel.stringValue = data.name
    cell.introLabel.stringValue = data.content
    cell.displayItem = data
    cell.cmdLabel.stringValue = "⌘\(dataIndex % 9 + 1)"
    data.updateFunction?(cell)
  }
  
  private func tabPressed() {
    guard datasource.count > 0 else { return }
    let selectedService = datasource[max(highlightedIndex, 0)]
    delegate?.tabPressed(service: selectedService)
  }
  
  private func enterPressed(withEvent event: NSEvent) {
    let withCmd = event.modifierFlags.contains(.command)
    guard
      withCmd || PreviewPopover.shared.isShown == true ,
      let servicePack = retrieveHighlighted()
    else { return }
    delegate?.serve(servicePack, withCmd: withCmd)
  }
  
  private func escPrssed() {
    if PreviewPopover.shared.isShown == true {
      PreviewPopover.shared.close()
    } else {
      #if DEBUG
      print("ESC pressed")
      #else
      (tableView.window as? BaseWindow)?.isHidden = true
      #endif
    }
  }
  
  private func quickSelect(withKeyCode keyCode: UInt16) {
    let keyCodeMap: [UInt16: Int] = [18: 1, 19: 2, 20: 3, 21: 4, 23: 5, 22: 6, 26: 7, 28: 8, 25: 9,
                                     83: 1, 84: 2, 85: 3, 86: 4, 87: 5, 88: 6, 89: 7, 91: 8, 92: 9]
    let selectedIndex = keyCodeMap[keyCode]! - 1
    guard
      selectedIndex < tableView.visibleCells.count,
      let cell = tableView.visibleCells[selectedIndex] as? ServiceCell,
      let servicePack = cell.displayItem as? ServicePack
    else { return }
    delegate?.serve(servicePack, withCmd: false)
  }
  
  private func terminateProgramProcess(_ event: NSEvent) {
    let warnBeforeExitEnabled = TonnerreSettings.get(fromKey: .warnBeforeExit) as? Bool ?? true
    let state = cmdQDoubleClick.click(event)
    switch (state, warnBeforeExitEnabled) {
    case (.completed, _), (_, false):
      #if DEBUG
      print("Double click trigered (\(String.CMD) Q)")
      #else
      TonnerreHelper.terminate()
      exit(0)
      #endif
    case (.ongoing(count: let count), _) where count == 1:
      delegate?.updatePlaceholder(string: " Double click \(String.CMD) Q to exit")
    default: break
    }
  }
}
