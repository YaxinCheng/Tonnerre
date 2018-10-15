//
//  ClipboardService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData

struct ClipboardService: TonnerreService, DeferedServiceProtocol {
  static let keyword: String = "cb"
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  let content: String = "Your records of recnet copies"
  var icon: NSImage {
    return #imageLiteral(resourceName: "clipboard").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  static let monitor = ClipboardMonitor(interval: 1, repeat: true) { (value, type) in
    CBRecord.recordInsert(value: value, type: type.rawValue, limit: 18)
  }
  
  static var isDisabled: Bool {
    get {
      let userDeafult = UserDefaults.shared
      return userDeafult.bool(forKey: "\(ClipboardService.self)+Disabled")
    } set {
      let userDeafult = UserDefaults.shared
      userDeafult.set(newValue, forKey: "\(ClipboardService.self)+Disabled")
      if newValue == true {
        ClipboardService.monitor.start()
      } else {
        ClipboardService.monitor.stop()
      }
    }
  }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    let copy: [DisplayProtocol]
    let query = input.joined(separator: " ")
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    if input.count > 0 {// If any content, copy to clipboard
      let text = query ?? "..."
      copy = [ DisplayableContainer<String>(name: "Copy: " + text, content: "Copy the text content to clipboard", icon: icon, priority: priority, innerItem: query) ]
      if !query.isEmpty {
        fetchRequest.predicate = NSPredicate(format: "value CONTAINS[cd] %@", query)
      }
    } else { copy = [] }
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
    let context = getContext()
    do {
      return copy + (try context.fetch(fetchRequest).map {
        if $0.type! == "public.file-url" {
          let name = $0.value!.components(separatedBy: "/").last ?? ""
          let url = URL(string: $0.value!)!
          let content = url.path
          let alterContent = "Show file in Finder"
          let icon = NSWorkspace.shared.icon(forFile: url.path)
          return DisplayableContainer(name: name, content: content, icon: icon, priority: priority, alterContent: alterContent, innerItem: url)
        } else if ($0.value?.lowercased().starts(with: "http://") ?? false)
          || ($0.value?.lowercased().starts(with: "https://") ?? false) {
          let name = $0.value!
          let url = URL(string: $0.value!)!
          let dateFmt = DateFormatter()
          dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
          let content = "Copied at \(dateFmt.string(from: $0.time!))"
          let alterContent = "Open copied URL in default browser"
          let browserURL = NSWorkspace.shared.urlForApplication(toOpen: url)
          let icon = NSWorkspace.shared.icon(forFile: browserURL?.path ?? "/Applications/Safari.app")
          return DisplayableContainer(name: name, content: content, icon: icon, priority: priority, alterContent: alterContent, innerItem: url)
        } else {
          let name = $0.value!.replacingOccurrences(of: "\n|\r", with: "\\\\n", options: .regularExpression)
          let dateFmt = DateFormatter()
          dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
          let content = "Copied at \(dateFmt.string(from: $0.time!))"
          let icon: NSImage = .notes ?? self.icon
          return DisplayableContainer(name: name, content: content, icon: icon, priority: priority, innerItem: $0.value!)
        }
      })
    } catch {
      return copy
    }
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    if let item = source as? DisplayableContainer<URL>, let url = item.innerItem {
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
    } else if let item = source as? DisplayableContainer<String>, let string = item.innerItem {
      pasteboard.setString(string, forType: .string)
    }
  }
  
}
