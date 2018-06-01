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
  var hasPreview: Bool { return false }
  var icon: NSImage { return #imageLiteral(resourceName: "Finder") }
  var content: String { return "Search file on your mac and open" }
  
  func process(input: [String]) -> [Displayable] {
    let query = input.joined(separator: " ") + "*"
    let indexStorage = IndexStorage()
    let index = indexStorage[associatedMode]
    return index.search(query: query, limit: 5 * 9, options: .defaultOption)
  }
}

struct FileNameSearchService: FileSearchService {
  let name = "Search files by names"
  
  let associatedMode: SearchMode = .name
  let keyword = "file"
  let arguments = ["Name"]
}

struct FileContentSearchService: FileSearchService {
  let name = "Search files by content"
  
  let associatedMode: SearchMode = .content
  let keyword = "content"
  let arguments = ["Keywords"]
}
