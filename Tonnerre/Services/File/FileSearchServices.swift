//
//  FileSearchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

protocol FileSearchService: TonnerreService {
  var associatedMode: SearchMode { get }
}

extension FileSearchService {
  var icon: NSImage { return #imageLiteral(resourceName: "Finder") }
  var content: String { return "Search file on your mac and open" }
  var alterContent: String? { return "Show in Finder" }
  var argUpperBound: Int { return Int.max }
  var argLowerBound: Int { return 1 }
  
  func prepare(input: [String]) -> [Displayable] {
    guard !(input.first?.isEmpty ?? false) else { return [self] }
    let query = input.joined(separator: " ") + "*"
    let indexStorage = IndexStorage()
    let index = indexStorage[associatedMode]
    return index.search(query: query, limit: 5 * 9, options: .default)
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let fileURL = source as? URL else { return }
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
  static let keyword = "file"
}

struct FileContentSearchService: FileSearchService {
  let name = "Search files by content"
  
  let associatedMode: SearchMode = .content
  static let keyword = "content"
}
