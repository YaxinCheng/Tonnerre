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
    CBRecord.recordInsert(value: value, type: type.rawValue, limit: 9)
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
      return copy + (try context.fetch(fetchRequest).compactMap {
        guard
          let type = $0.type,
          let value = $0.value?.replacingOccurrences(of: "\n|\r", with: "\\\\n", options: .regularExpression),
          let time = $0.time
        else { return nil }
        if type == "public.file-url" {
          let name = value.components(separatedBy: "/").last?
            .removingPercentEncoding ?? ""
          guard let url = URL(string: value) else { return nil }
          let content = url.path
          let alterContent = "Show file in Finder"
          let icon = NSWorkspace.shared.icon(forFile: url.path)
          return DisplayableContainer(name: name, content: content, icon: icon, alterContent: alterContent, innerItem: url)
        } else if value.lowercased().starts(with: "http://")
          || value.lowercased().starts(with: "https://") {
          guard let url = URL(string: value) else { return nil }
          let dateFmt = DateFormatter()
          dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
          let content = "Copied at \(dateFmt.string(from: time))"
          let alterContent = "Open copied URL in default browser"
          let browserURL = NSWorkspace.shared.urlForApplication(toOpen: url)
          let icon = NSWorkspace.shared.icon(forFile: browserURL?.path ?? "/Applications/Safari.app")
          return DisplayableContainer(name: value, content: content, icon: icon, alterContent: alterContent, innerItem: url)
        } else {
          let dateFmt = DateFormatter()
          dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
          let content = "Copied at \(dateFmt.string(from: time))"
          let icon: NSImage = .notes ?? self.icon
          return DisplayableContainer(name: value, content: content, icon: icon, innerItem: $0.value)
        }
      })
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
