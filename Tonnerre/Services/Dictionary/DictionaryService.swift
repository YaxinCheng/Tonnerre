//
//  DictionaryService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import CoreServices
import Cocoa

struct DictionarySerivce: TonnerreService {
  let icon: NSImage = #imageLiteral(resourceName: "dictionary")
  let content: String = "Find definition for word in dictionary"
  let name: String = "Define words..."
  let keyword: String = "define"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let hasPreview: Bool = false
  
  func prepare(input: [String]) -> [Displayable] {
    let query = input.joined(separator: " ")
    var queriedResult: DisplayableContainer<URL> = DisplayableContainer<URL>(name: query, content: "\"\(query)\" is not found", icon: icon)
    autoreleasepool {
      let termRange = DCSGetTermRangeInString(nil, query as CFString, 0)
      if termRange.location != kCFNotFound {
        if let definition = DCSCopyTextDefinition(nil, query as CFString, termRange)?.takeRetainedValue() {
          let (startIndex, endIndex) = (query.index(query.startIndex, offsetBy: termRange.location),
                                        query.index(query.startIndex, offsetBy: termRange.length))
          let foundTerm = String(query[startIndex..<endIndex])
          let urlEncoded = foundTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? foundTerm
          let dictURL = URL(string: String(format: "dict://%@", urlEncoded))!
          queriedResult = DisplayableContainer(name: foundTerm, content: definition as String, icon: icon, innerItem: dictURL)
        }
      } else {
        queriedResult = DisplayableContainer<URL>(name: query, content: "\"\(query)\" is not found", icon: icon)
      }
    }
    return [queriedResult]
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    NSWorkspace.shared.open(request)
  }
}
