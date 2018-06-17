//
//  ServiceCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Quartz

class ServiceCell: NSCollectionViewItem, ThemeProtocol, DisplayableCellProtocol {
  
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var cmdLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  var displayItem: Displayable?
  var popoverView = NSPopover()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    theme = .currentTheme
    popoverView.contentSize = NSSize(width: 450, height: 280)
    popoverView.behavior = .transient
  }
  
  var theme: TonnerreTheme {
    get {
      return .currentTheme
    } set {
      iconView.theme = newValue
      serviceLabel.textColor = newValue.imgColour
      cmdLabel.textColor = newValue.imgColour
      introLabel.textColor = newValue.imgColour
    }
  }
  
  func preview() {
    guard
      let url = (displayItem as? URL) ?? (displayItem as? DisplayableContainer<URL>)?.innerItem,
      let name = (displayItem as? URL)?.deletingPathExtension().lastPathComponent ?? (displayItem as? DisplayableContainer<URL>)?.name,
      !popoverView.isShown
    else { return }
    guard let qlView = QLPreviewView(frame: NSRect(x: 0, y: 0, width: 450, height: 280), style: .normal) else { return }
    let viewController = NSViewController()
    qlView.previewItem = PreviewItem(title: name, url: url)
    qlView.shouldCloseWithWindow = true
    viewController.view = qlView
    let cellRect = view.convert(NSRect(x: -40, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height), to: view)
    popoverView.contentViewController = viewController
    popoverView.show(relativeTo: cellRect, of: view, preferredEdge: .maxX)
  }
  
  override func pressureChange(with event: NSEvent) {
    guard event.stage == 2 && !popoverView.isShown else { return }
    preview()
  }
}

