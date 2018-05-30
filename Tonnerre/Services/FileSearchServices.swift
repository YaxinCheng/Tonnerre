//
//  FileSearchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

protocol FileSearchService: TonnerreService where resultType == URL {
  var associatedMode: SearchMode { get }
}

extension FileSearchService {
  var icon: NSImage { return #imageLiteral(resourceName: "tonnerre") }// Temporary, will be replaced
  var hasPreview: Bool { return false }
  func process(input: [String]) -> [URL] {
    let query = input.joined(separator: " ")
    let indexStorage = IndexStorage()
    let index = indexStorage[associatedMode]
    return index.search(query: query, limit: 9 * 9, options: .defaultOption)
  }
}

struct FileNameSearchService: FileSearchService {
  let associatedMode: SearchMode = .name
  let keywords = ["file", "f"]
  let arguments = ["Name"]
}

struct FileContentSearchService: FileSearchService {
  let associatedMode: SearchMode = .content
  let keywords = ["content", "in"]
  let arguments = ["Keywords"]
}
