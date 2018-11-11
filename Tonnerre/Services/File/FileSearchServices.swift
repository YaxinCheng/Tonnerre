//
//  FileSearchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol FileSearchService: BuiltInProvider {
  var associatedMode: SearchMode { get }
}

extension FileSearchService {
  var icon: NSImage { return .finder }
  var content: String { return "Search file on your mac and open" }
  var alterContent: String? { return "Show file in Finder" }
  var argUpperBound: Int { return Int.max }
  var argLowerBound: Int { return 1 }
  
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    guard !(input.first?.isEmpty ?? false) else { return [self] }
    let query = input.joined(separator: " ") + "*"
    let indexStorage = IndexStorage()
    let index = indexStorage[associatedMode]
    return index.search(query: query, limit: 5 * 9, options: .default).map {
      DisplayableContainer(name: $0.deletingPathExtension().lastPathComponent, content: $0.path, icon: NSWorkspace.shared.icon(forFile: $0.path), innerItem: $0, placeholder: $0.deletingPathExtension().lastPathComponent)
    }
  }
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    guard let fileURL = (service as? DisplayableContainer<URL>)?.innerItem else { return }
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
  
  let associatedMode: SearchMode = .name
  let keyword = "file"
}

struct FileContentSearchService: FileSearchService {
  let name = "Search files by content"
  
  let associatedMode: SearchMode = .content
  let keyword = "content"
}
