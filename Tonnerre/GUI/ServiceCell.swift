//
//  ServiceCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Quartz
import LiteTableView

fileprivate final class PreviewItem: NSObject, QLPreviewItem {
  let previewItemTitle: String!
  let previewItemURL: URL!
  
  init(title: String, url: URL) {
    previewItemURL = url
    previewItemTitle = title
    super.init()
  }
}

protocol ServiceCellDelegate: class {
  func cellDoubleClicked()
}

private extension NSPopover {
  convenience init(withDelegate delegate: NSPopoverDelegate) {
    self.init()
    self.contentSize = NSSize(width: 500, height: 700)
    self.behavior = .transient
    self.delegate = delegate
  }
}

final class ServiceCell: LiteTableCell {
  
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var cmdLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  var displayItem: ServicePack? = nil
  weak var delegate: ServiceCellDelegate?
  var popoverView: NSPopover!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    displayItem = nil
    delegate = nil
    popoverView = NSPopover(withDelegate: self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    popoverView = NSPopover(withDelegate: self)
  }
  
  override var highlightedColour: NSColor {
    if #available(OSX 10.14, *) {
      return NSColor.controlAccentColor.withAlphaComponent(0.8)
    } else {
      return super.highlightedColour.withAlphaComponent(0.8)
    }
  }
  
  func preview() {
    guard !popoverView.isShown else { return }
    let viewController = NSViewController()
    let constructView: (URL, String) -> NSView = { [unowned self] in
      let qlView = QLPreviewView(frame: NSRect(x: 0, y: 0, width: self.popoverView.contentSize.width, height: self.popoverView.contentSize.height), style: .normal)!
      qlView.previewItem = PreviewItem(title: $1, url: $0)
      qlView.shouldCloseWithWindow = true
      return qlView
    }
    guard case .service(_, let service)? = displayItem else { return }
    if let container = service as? DisplayableContainer<URL>,
      let url = container.innerItem {
      if let buildInVC = container.extraContent as? NSViewController {
        viewController.view = buildInVC.view
      } else {
        viewController.view = constructView(url, container.name)
      }
    } else if let container = service as? AsyncedDisplayableContainer<URL>,
      let url = container.innerItem {
      viewController.view = constructView(url, container.name)
    } else if let container = service as? WebExt,
      let url = URL(string: container.rawURL) {
      viewController.view = constructView(url, container.name)
    } else { return }
    
    let cellRect = view.convert(NSRect(x: -40, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height), to: view)
    popoverView.contentViewController = viewController
    popoverView.show(relativeTo: cellRect, of: view, preferredEdge: .maxX)
  }
  
  override func pressureChange(with event: NSEvent) {
    guard event.stage == 2 && !popoverView.isShown else { return }
    preview()
  }
  
  override func mouseUp(with event: NSEvent) {
    guard event.clickCount == 2 else { super.mouseUp(with: event); return }
    delegate?.cellDoubleClicked()
  }
}

extension ServiceCell: NSPopoverDelegate {
  func popoverDidClose(_ notification: Notification) {
    popoverView.contentViewController = nil
  }
}
