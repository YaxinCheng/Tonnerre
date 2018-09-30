//
//  ServiceCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Quartz

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

final class ServiceCell: NSCollectionViewItem {
  
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var cmdLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  var displayItem: DisplayProtocol?
  weak var delegate: ServiceCellDelegate?
  var popoverView = NSPopover()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    popoverView.contentSize = NSSize(width: 500, height: 700)
    popoverView.behavior = .transient
    popoverView.delegate = self
  }
  
  var theme: TonnerreTheme {
    get {
      return .current
    } set {
      serviceLabel.textColor = newValue.imgColour
      cmdLabel.textColor = newValue.imgColour
      introLabel.textColor = newValue.imgColour
      switch newValue {
      case .dark: iconView.shadow = nil
      case .light: iconView.shadow = {
          let shadow = NSShadow()
          shadow.shadowColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5)
          shadow.shadowBlurRadius = 1
          shadow.shadowOffset = NSSize(width: 2, height: 3)
          return shadow
        }()
      }
    }
  }
  
  var highlighted: Bool {
    set {
      DispatchQueue.main.async { [weak self] in
        if newValue {
          self?.view.layer?.backgroundColor = self?.theme.highlightColour.cgColor
        } else {
          self?.view.layer?.backgroundColor = .clear
        }
      }
    } get {
      return view.layer?.backgroundColor == theme.highlightColour.cgColor
    }
  }
  
  override func viewWillAppear() {
    theme = .current
  }
  
  func preview() {
    guard !popoverView.isShown else { return }
    let viewController: NSViewController
    let constructViewController: (URL, String) -> NSViewController = { [unowned self] in
      let qlView = QLPreviewView(frame: NSRect(x: 0, y: 0, width: self.popoverView.contentSize.width, height: self.popoverView.contentSize.height), style: .normal)!
      qlView.previewItem = PreviewItem(title: $1, url: $0)
      qlView.shouldCloseWithWindow = true
      let viewController = NSViewController()
      viewController.view = qlView
      return viewController
    }
    if let container = displayItem as? DisplayableContainer<URL>,
      let url = container.innerItem
    {
      viewController = constructViewController(url, container.name)
    } else if let container = displayItem as? WebExt,
      let url = URL(string: container.rawURL) {
      viewController = constructViewController(url, container.name)
    }
    else if let container = displayItem as? DisplayableContainer<NSViewController>,
      let vc = container.innerItem {
      viewController = vc
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
