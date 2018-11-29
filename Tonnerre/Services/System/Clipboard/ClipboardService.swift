//
//  ClipboardService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

struct ClipboardService: BuiltInProvider {
  let keyword: String = "cb"
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  let content: String = "Your records of recnet copies"
  let icon: NSImage = #imageLiteral(resourceName: "clipboard")
  let defered: Bool = true
  
  static let monitor = ClipboardMonitor(interval: 1, repeat: true) { (value, type) in
    let frontMostApp = NSWorkspace.shared.frontmostApplication
    CBRecord.recordInsert(value: value, type: type.rawValue, appURL: frontMostApp?.bundleURL, limit: 9)
  }
  
  private func wrap(record: CBRecord) -> DisplayProtocol? {
    guard
      let type = record.type,
      let value = record.value as? NSAttributedString,
      let time = record.time
    else { return nil }
    let stringValue = value.string.replacingOccurrences(of: "\n|\r", with: "\\\\n", options: .regularExpression)
    if type == "public.file-url" {
      guard
        let url = URL(string: stringValue),
        FileManager.default.fileExists(atPath: url.path)
      else { return nil }
      let name = stringValue.components(separatedBy: "/").last?
        .removingPercentEncoding ?? ""
      let content = url.path
      let alterContent = "Show file in Finder"
      let icon = NSWorkspace.shared.icon(forFile: url.path)
      return DisplayableContainer(name: name, content: content, icon: icon, alterContent: alterContent, innerItem: url)
    } else if stringValue.lowercased().starts(with: "http://")
      || stringValue.lowercased().starts(with: "https://") {
      guard
        let url = URL(string: stringValue)
      else { return nil }
      let dateFmt = DateFormatter()
      dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
      let sourceContent = record.source == nil ? "" : " from: \(record.source!.path!.deletingPathExtension().lastPathComponent),"
      let content = "Copied\(sourceContent) at \(dateFmt.string(from: time))"
      let alterContent = "Open copied URL in default browser"
      let browser: Browser = .default
      return DisplayableContainer(name: stringValue, content: content, icon: browser.icon ?? .safari, alterContent: alterContent, innerItem: url)
    } else {
      let appURL = record.source?.path
      let iconFromApp: NSImage? = appURL == nil ? nil : NSWorkspace.shared.icon(forFile: appURL!.path)
      let dateFmt = DateFormatter()
      dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
      let sourceContent = appURL == nil ? "" : " from: \(appURL!.deletingPathExtension().lastPathComponent),"
      let content = "Copied\(sourceContent) at \(dateFmt.string(from: time))"
      let icon: NSImage = iconFromApp ?? self.icon
      return DisplayableContainer(name: stringValue, content: content, icon: icon, innerItem: value)
    }
  }
  
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    let copy: [DisplayProtocol]
    let query = input.joined(separator: " ")
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    if input.count > 0 {// If any content, copy to clipboard
      let text = query ?? "..."
      copy = [ DisplayableContainer<String>(name: "Copy: " + text, content: "Copy the text content to clipboard", icon: icon, innerItem: query) ]
    } else { copy = [] }
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
    let context = getContext()
    do {
      let clipboardRecords = try context.fetch(fetchRequest)
      let context = getContext()
      var displayableRecords: [DisplayProtocol] = []
      for record in clipboardRecords {
        if let wrapped = wrap(record: record) {
          displayableRecords.append(wrapped)
        } else {
          context.delete(record)
        }
      }
      try context.save()
      return copy + displayableRecords
    } catch {
      return copy
    }
  }
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    switch service {
    case let item as DisplayableContainer<URL> where item.innerItem != nil:
      let url = item.innerItem!
      switch (FileManager.default.fileExists(atPath: url.path), withCmd) {
      case (true, true): NSWorkspace.shared.activateFileViewerSelecting([url])
      case (true, false): pasteboard.writeObjects([url as NSURL])
      case (false, true): NSWorkspace.shared.open(url)
      case (false, false): pasteboard.setString(url.absoluteString, forType: .string)
      }
    case let item as DisplayableContainer<NSAttributedString> where item.innerItem != nil:
      pasteboard.writeObjects([item.innerItem!])
    case let item as DisplayableContainer<String> where item.innerItem != nil:
      let attributed = NSAttributedString(string: item.innerItem!, attributes: [.font: NSFont.systemFont(ofSize: 17),
                                                                                .foregroundColor: NSColor.labelColor])
      pasteboard.writeObjects([attributed])
    default: return
    }
  }
  
}
