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

final class ServiceCell: LiteTableCell {
  
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var serviceLabel: NSTextField!
  @IBOutlet weak var cmdLabel: NSTextField!
  @IBOutlet weak var introLabel: NSTextField!
  var displayItem: ServicePack? = nil
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    displayItem = nil
  }
  
  override var highlightedColour: NSColor {
    if #available(OSX 10.14, *) {
      return NSColor.controlAccentColor.withAlphaComponent(0.8)
    } else {
      return super.highlightedColour.withAlphaComponent(0.8)
    }
  }
  
  func preview() {
    guard !PreviewPopover.shared.isShown else { return }
    let viewController = NSViewController()
    let constructView: (URL, String) -> NSView = { 
      let qlView = QLPreviewView(frame: NSRect(x: 0, y: 0, width: PreviewPopover.shared.contentSize.width, height: PreviewPopover.shared.contentSize.height), style: .normal)!
      qlView.previewItem = PreviewItem(title: $1, url: $0)
      qlView.shouldCloseWithWindow = true
      return qlView
    }
    guard case .service(_, let service)? = displayItem else { return }
    if let container = service as? DisplayableContainer<URL>,
      let url = container.innerItem {
      if let buildInView = container.extraContent as? NSView {
        viewController.view = buildInView
      } else {
        viewController.view = constructView(url, container.name)
      }
    } else if let container = service as? AsyncedDisplayableContainer<URL>,
      let url = container.innerItem {
      viewController.view = constructView(url, container.name)
    } else if let container = service as? DisplayableContainer<Error> {
      let textViewBuilder: (String)->NSView = {
        let targetView: NSView
        let textView: NSTextView
        if #available(OSX 10.14, *) {
          targetView = NSTextView.scrollablePlainDocumentContentTextView()
          textView = (targetView as! NSScrollView).documentView as! NSTextView
        } else {
          textView = NSTextView()
          targetView = textView
        }
        textView.drawsBackground = false
        textView.string = $0
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 17)
        return targetView
      }
      viewController.view = textViewBuilder("\n" + container.name + "\n\n" + container.content)
    } else { return }
    let cellRect = view.convert(NSRect(x: -40, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height), to: view)
    PreviewPopover.shared.contentViewController = viewController
    PreviewPopover.shared.show(relativeTo: cellRect, of: view, preferredEdge: .maxX)
  }
}
