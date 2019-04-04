//
//  FileSearchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import TonnerreSearch

protocol FileSearchService: BuiltInProvider {
  var associatedIndex: TonnerreIndex? { get }
}

extension FileSearchService {
  var icon: NSImage { return .finder }
  var content: String { return "Search file on your mac and open" }
  var alterContent: String? { return "Show file in Finder" }
  var argUpperBound: Int { return Int.max }
  var argLowerBound: Int { return 1 }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    guard !(input.first?.isEmpty ?? false) else { return [self] }
    let query = input.joined(separator: " ") + "*"
    return (associatedIndex?.search(query: query, limit: 5 * 9, options: .default) ?? []).map {
      DisplayContainer(name: $0.deletingPathExtension().lastPathComponent, content: $0.path, icon: NSWorkspace.shared.icon(forFile: $0.path), innerItem: $0, placeholder: $0.deletingPathExtension().lastPathComponent)
    }
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    guard let fileURL = (service as? DisplayContainer<URL>)?.innerItem else { return }
    let workspace = NSWorkspace.shared
    if withCmd {
      workspace.activateFileViewerSelecting([fileURL])
    } else {
      workspace.open(fileURL)
    }
  }
}

struct FileNameSearchService: FileSearchService {
  let name = "Search files by names"
  let defaultKeyword = "file"
  
  var associatedIndex: TonnerreIndex? {
    return IndexFactory.name
  }
}

struct FileContentSearchService: FileSearchService {
  let name = "Search files by content"
  let defaultKeyword = "content"
  
  var associatedIndex: TonnerreIndex? {
    return IndexFactory.content
  }
}
