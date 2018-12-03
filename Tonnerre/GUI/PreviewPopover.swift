//
//  PreviewPopover.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Quartz

final class PreviewPopover: NSPopover, NSPopoverDelegate {
  private final let maxSize = NSSize(width: 500, height: 700)
  private final let minSize = NSSize(width: 300, height: 40)
  
  private final class PreviewItem: NSObject, QLPreviewItem {
    let previewItemTitle: String!
    let previewItemURL: URL!
    
    init(title: String, url: URL) {
      previewItemURL = url
      previewItemTitle = title
      super.init()
    }
  }
  
  private(set) static var shared = PreviewPopover()
  
  private override init() {
    super.init()
    self.behavior = .transient
    self.delegate = self
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func popoverDidClose(_ notification: Notification) {
    PreviewPopover.shared = PreviewPopover()
    contentViewController = nil
  }
  
  func present(item: DisplayProtocol, relativeTo positioningRect: NSRect, of positioningView: NSView) {
    guard !isShown else { return }
    let displayView: NSView
    switch item {
    case let urlItem as AsyncedDisplayableContainer<URL>
      where urlItem.innerItem != nil:
      displayView = QLPreview(title: urlItem.name, url: urlItem.innerItem!)
    case let urlItem as DisplayableContainer<URL>
      where urlItem.innerItem != nil && urlItem.innerItem?.scheme != "dict":
      displayView = QLPreview(title: urlItem.name, url: urlItem.innerItem!)
    case let errorItem as DisplayableContainer<Error>
      where errorItem.innerItem != nil:
      let text = NSMutableAttributedString(string: "Error",
                                           attributes: [.font: NSFont.systemFont(ofSize: 23, weight: .black),
                                                        .foregroundColor: NSColor.labelColor])
      let content = NSAttributedString(string: "\n\n\(errorItem.innerItem!)",
        attributes: [.font: NSFont.systemFont(ofSize: 17),
                     .foregroundColor: NSColor.labelColor])
      text.append(content)
      displayView = TextView(text: text)
    case let stringItem as DisplayableContainer<NSAttributedString>
      where stringItem.innerItem != nil:
      displayView = TextView(text: stringItem.innerItem!)
    case let anyItem where anyItem.content.count > 20:
      displayView = TextView(text: NSAttributedString(string: anyItem.content,
                                                      attributes: [.font: NSFont.systemFont(ofSize: 17),
                                                                  .foregroundColor: NSColor.labelColor]))
    default: return
    }
    let viewController = NSViewController()
    viewController.view = displayView
    contentViewController = viewController
    show(relativeTo: positioningRect, of: positioningView, preferredEdge: .maxX)
  }
}

private extension PreviewPopover {
  private func QLPreview(title: String, url: URL) -> QLPreviewView {
    contentSize = maxSize
    let qlView = QLPreviewView(frame: NSRect(x: 0, y: 0, width: maxSize.width, height: maxSize.height), style: .normal)!
    qlView.previewItem = PreviewItem(title: title, url: url)
    qlView.shouldCloseWithWindow = true
    return qlView
  }
  
  private func TextView(text: String) -> NSView {
    return TextView(text: NSAttributedString(string: text))
  }
  
  private func TextView(text: NSAttributedString) -> NSView {
    let targetView: NSView
    let textView: NSTextView
    if #available(OSX 10.14, *) {
      targetView = NSTextView.scrollablePlainDocumentContentTextView()
      textView = (targetView as! NSScrollView).documentView as! NSTextView
    } else {
      textView = NSTextView()
      targetView = textView
    }
    textView.textStorage?.append(text)
    textView.drawsBackground = false
    textView.isEditable = false
    contentSize = { maxSize, minSize, text in
      let fitSize = text.boundingRect(with: NSSize(width: maxSize.width, height: 0),
                                      options: [.usesFontLeading, .usesLineFragmentOrigin]).size
      return NSSize(width: max(min(fitSize.width, maxSize.width), minSize.width),
                    height: max(min(fitSize.height, maxSize.height), minSize.height))
    }(maxSize, minSize, text)
    return targetView
  }
}

