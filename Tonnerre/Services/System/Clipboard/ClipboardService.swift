//
//  ClipboardService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

struct ClipboardService: SystemService {
  static let keyword: String = "cb"
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  var icon: NSImage {
    return #imageLiteral(resourceName: "clipboard").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  static let monitor = ClipboardMonitor(interval: 1, repeat: true) { (value, type) in
    CBRecord.recordInsert(value: value, type: type.rawValue, limit: 18)
  }
  
  static var isDisabled: Bool {
    get {
      let userDeafult = UserDefaults.standard
      return userDeafult.bool(forKey: "\(ClipboardService.self)+Disabled")
    } set {
      let userDeafult = UserDefaults.standard
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
      let text = query.isEmpty ? "..." : query
      copy = [ DisplayableContainer<String>(name: "Copy: " + text, content: "Copy the text content to clipboard", icon: icon, innerItem: query) ]
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
          let icon = NSWorkspace.shared.icon(forFile: url.path)
          return DisplayableContainer(name: name, content: content, icon: icon, innerItem: url)
        } else {
          let name = $0.value!
          let dateFmt = DateFormatter()
          dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
          let content = "Copied at \(dateFmt.string(from: $0.time!))"
          let icon = self.icon
          return DisplayableContainer(name: name, content: content, icon: icon, innerItem: $0.value!)
        }
      })
    } catch {
      return copy
    }
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    NSPasteboard.general.clearContents()
    if let item = source as? DisplayableContainer<URL>, let url = item.innerItem {
      if withCmd {
        NSWorkspace.shared.activateFileViewerSelecting([url])
      } else if FileManager.default.fileExists(atPath: url.path) {
        NSPasteboard.general.setString(url.absoluteString, forType: .fileURL)
      } else {
        NSPasteboard.general.setString(url.path, forType: .string)
      }
    } else if let item = source as? DisplayableContainer<String>, let string = item.innerItem {
      NSPasteboard.general.setString(string, forType: .string)
    }
  }
  
}
