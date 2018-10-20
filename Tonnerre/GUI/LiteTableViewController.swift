//
//  LiteTableViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-18.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class LiteTableViewController: NSViewController {
  
  var datasource: [ServicePack] = [] {
    didSet {
      HeightConstraint.constant = CellHeight * CGFloat(min(9, datasource.count))
      highlightedIndex = -1
      (view as! LiteTableView).reload()
      if case .service(_, _)? = datasource.first {
        delegate?.serviceHighlighted(service: datasource.first)
      } else {
        delegate?.serviceHighlighted(service: nil)
      }
      delegate?.updatePlaceholder(service: datasource.first)
    }
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
    
    if let tableView = view as? LiteTableView {
      tableView.liteDelegate   = self
      tableView.liteDataSource = self
      tableView.register(nib: NSNib(nibNamed: "ServiceCell", bundle: .main)!, withIdentifier: .ServiceCell)
      let allowedKeys: [UInt16] = [48]
      tableView.allowedKeyCodes.formUnion(allowedKeys)
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
      if datasource.count == 0 && event.keyCode == 126 {
        delegate?.retrieveLastQuery()
      }
      guard datasource.count > 0 else { return }
      highlightedIndex += event.keyCode == 125 ? 1 : -1
      let selectedService = datasource[max(highlightedIndex, 0)]
      delegate?.serviceHighlighted(service: selectedService)
      delegate?.updatePlaceholder(service: selectedService)
    case 48: // tab
      let selectedService = datasource[max(highlightedIndex, 0)]
      delegate?.tabPressed(service: selectedService)
    default:
      break
    }
  }
  
  func cellReuseThreshold(_ tableView: LiteTableView) -> Int {
    return 9
  }
  
  func numberOfCells(_ tableView: LiteTableView) -> Int {
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
    return cell
  }
}
