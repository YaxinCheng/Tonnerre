//
//  FileSearchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

struct FileNameSearchService: FileSearchService {
  let keywords = ["file", "f"]
  let arguments = ["Name"]
  
  func process(input: [String]) -> [URL] {
    return FileNameSearchService.core.search(keyword: input.joined(separator: " "), in: .name)
  }
}

struct FileContentSearchService: FileSearchService {
  let keywords = ["content", "in"]
  let arguments = ["Keywords"]
  
  func process(input: [String]) -> [URL] {
    return FileNameSearchService.core.search(keyword: input.joined(separator: " "), in: .content)
  }
}
