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
  let name: String = "Clipboard Records"
  let content: String = "Your records of recent copies"
  let icon: NSImage = #imageLiteral(resourceName: "clipboard")
  let defered: Bool = true
  
  private func wrap(record: CBRecord) -> DisplayItem? {
    guard
      let type = record.type,
      let value = record.value as? NSAttributedString,
      let time = record.time
    else { return nil }
    let stringValue = value.string.replacingOccurrences(of: "\n|\r", with: "\\\\n", options: .regularExpression)
    let dateFmt = DateFormatter()
    dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
    let timestamp = "Copied at \(dateFmt.string(from: time))"
    if type == "public.file-url" {
      return wrapFileURLRecord(value: stringValue)
    } else if stringValue.lowercased().starts(with: "http://")
      || stringValue.lowercased().starts(with: "https://") {
      return wrapHttpURLRecord(value: stringValue, timestamp: timestamp)
    } else if value.containsAttachments == true {
      return wrapImageRecord(value: stringValue, timestamp: timestamp, image: value)
    } else {
      return DisplayContainer(name: stringValue, content: timestamp, icon: #imageLiteral(resourceName: "text"), innerItem: value, placeholder: "")
    }
  }
  
  private func wrapFileURLRecord(value: String) -> DisplayItem? {
    guard
      let url = URL(string: value),
      FileManager.default.fileExists(atPath: url.path)
    else { return nil }
    let name = value.components(separatedBy: "/").last?
      .removingPercentEncoding ?? ""
    let content = url.path
    let alterContent = "Show file in Finder"
    let icon = NSWorkspace.shared.icon(forFile: url.path)
    return DisplayContainer(name: name, content: content, icon: icon, alterContent: alterContent, innerItem: url, placeholder: "")
  }
  
  private func wrapHttpURLRecord(value: String, timestamp: String) -> DisplayItem? {
    guard
      let url = URL(string: value)
    else { return nil }
    let alterContent = "Open copied URL in default browser"
    let browser: Browser? = .default
    return DisplayContainer(name: value, content: timestamp, icon: browser?.icon ?? .safari, alterContent: alterContent, innerItem: url, placeholder: "")
  }
  
  private func wrapImageRecord(value: String, timestamp: String, image: NSAttributedString) -> DisplayItem? {
    let strippedString = String(value.unicodeScalars.filter { $0.isASCII })
    let title = strippedString.isEmpty ? "Copied Image" : strippedString
    return DisplayContainer(name: title, content: timestamp, icon: #imageLiteral(resourceName: "image"), innerItem: image, placeholder: "")
  }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    let copy: [DisplayItem]
    let query = input.joined(separator: " ")
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    if input.count > 0 {// If any content, copy to clipboard
      let text = query.isEmpty ? "..." : query
      copy = [ DisplayContainer<String>(name: "Copy: " + text, content: "Copy the text content to clipboard", icon: icon, innerItem: query, placeholder: "") ]
    } else { copy = [] }
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
    let context = getContext()
    do {
      let clipboardRecords = try context.fetch(fetchRequest)
      let context = getContext()
      var displayableRecords: [DisplayItem] = []
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
  
  func serve(service: DisplayItem, withCmd: Bool) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    switch service {
    case let item as DisplayContainer<URL> where item.innerItem != nil:
      let url = item.innerItem!
      switch (FileManager.default.fileExists(atPath: url.path), withCmd) {
      case (true, true): NSWorkspace.shared.activateFileViewerSelecting([url])
      case (true, false): pasteboard.writeObjects([url as NSURL])
      case (false, true): NSWorkspace.shared.open(url)
      case (false, false): pasteboard.setString(url.absoluteString, forType: .string)
      }
    case let item as DisplayContainer<NSAttributedString> where item.innerItem != nil:
      pasteboard.writeObjects([item.innerItem!])
    case let item as DisplayContainer<String> where item.innerItem != nil:
      let attributed = NSAttributedString(string: item.innerItem!, attributes: [.font: NSFont.systemFont(ofSize: 17),
                                                                                .foregroundColor: NSColor.labelColor])
      pasteboard.writeObjects([attributed])
    default: return
    }
  }
  
}
