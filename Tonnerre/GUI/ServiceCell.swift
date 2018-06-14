//
//  ServiceCell.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Quartz

class ServiceCell: NSCollectionViewItem, ThemeProtocol {
  
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var cmdLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  var displayItem: Displayable?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    theme = .currentTheme
  }
  
  var highlighted: Bool = false {
    didSet {
      DispatchQueue.main.async { [weak self] in
        if self?.highlighted ?? false {
          self?.view.layer?.backgroundColor = NSColor(calibratedRed: 99/255, green: 147/255, blue: 1, alpha: 0.6).cgColor
        } else {
          self?.view.layer?.backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0).cgColor
        }
      }
    }
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
      let name = (displayItem as? URL)?.deletingPathExtension().lastPathComponent ?? (displayItem as? DisplayableContainer<URL>)?.name
    else { return }
    let width = 450
    guard let qlView = QLPreviewView(frame: NSRect(x: 0, y: 0, width: width, height: 320), style: .normal) else { return }
    let viewController = NSViewController()
    viewController.view = qlView
    qlView.previewItem = PreviewItem(title: name, url: url)
    let cellRect = view.convert(NSRect(x: -40, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height), to: view)
    presentViewController(viewController, asPopoverRelativeTo: cellRect, of: view, preferredEdge: .maxX, behavior: .transient)
  }
}

