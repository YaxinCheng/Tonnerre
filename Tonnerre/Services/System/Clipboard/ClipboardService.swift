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
      let value = record.value?.replacingOccurrences(of: "\n|\r", with: "\\\\n", options: .regularExpression),
      let time = record.time
    else { return nil }
    if type == "public.file-url" {
      guard
        let url = URL(string: value),
        FileManager.default.fileExists(atPath: url.path)
      else { return nil }
      let name = value.components(separatedBy: "/").last?
        .removingPercentEncoding ?? ""
      let content = url.path
      let alterContent = "Show file in Finder"
      let icon = NSWorkspace.shared.icon(forFile: url.path)
      return DisplayableContainer(name: name, content: content, icon: icon, alterContent: alterContent, innerItem: url)
    } else if value.lowercased().starts(with: "http://")
      || value.lowercased().starts(with: "https://") {
      guard
        let url = URL(string: value)
      else { return nil }
      let dateFmt = DateFormatter()
      dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
      let sourceContent = record.application == nil ? "" : " from: \(record.application!.deletingPathExtension().lastPathComponent),"
      let content = "Copied\(sourceContent) at \(dateFmt.string(from: time))"
      let alterContent = "Open copied URL in default browser"
      let browser: Browser = .default
      return DisplayableContainer(name: value, content: content, icon: browser.icon ?? .safari, alterContent: alterContent, innerItem: url)
    } else {
      let appURL = record.application
      let iconFromApp: NSImage? = appURL == nil ? nil : NSWorkspace.shared.icon(forFile: appURL!.path)
      let dateFmt = DateFormatter()
      dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
      let sourceContent = appURL == nil ? "" : " from: \(appURL!.deletingPathExtension().lastPathComponent),"
      let content = "Copied\(sourceContent) at \(dateFmt.string(from: time))"
      let icon: NSImage = iconFromApp ?? self.icon
      return DisplayableContainer(name: value, content: content, icon: icon, innerItem: value)
    }
  }
  
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    let copy: [DisplayProtocol]
    let query = input.joined(separator: " ")
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    if input.count > 0 {// If any content, copy to clipboard
      let text = query ?? "..."
      copy = [ DisplayableContainer<String>(name: "Copy: " + text, content: "Copy the text content to clipboard", icon: icon, innerItem: query) ]
      if !query.isEmpty {
        fetchRequest.predicate = NSPredicate(format: "value CONTAINS[cd] %@", query)
      }
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
    if let item = service as? DisplayableContainer<URL>, let url = item.innerItem {
      if FileManager.default.fileExists(atPath: url.path) {
        if withCmd {
          NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
          pasteboard.writeObjects([url as NSURL])
        }
      } else {
        if withCmd {
          NSWorkspace.shared.open(url)
        } else {
          pasteboard.setString(url.absoluteString, forType: .string)
        }
      }
    } else if let item = service as? DisplayableContainer<String>, let string = item.innerItem {
      pasteboard.setString(string, forType: .string)
    }
  }
  
}
