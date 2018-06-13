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
  static let keyword: String = "define"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let hasPreview: Bool = false
  private static let historyStorage = QueryStack<Displayable>(size: 8)
  
  func prepare(input: [String]) -> [Displayable] {
    guard input.count > 0, !input[0].isEmpty else { return [self] + DictionarySerivce.historyStorage.values() }
    let query = input.joined(separator: " ")
    let termRange = DCSGetTermRangeInString(nil, query as CFString, 0)
    guard
      termRange.location != kCFNotFound,
      let definition = DCSCopyTextDefinition(nil, query as CFString, termRange)?.takeRetainedValue()
    else { return [DisplayableContainer<URL>(name: query, content: "\"\(query)\" is not found", icon: icon)] }
    let (startIndex, endIndex) = (query.index(query.startIndex, offsetBy: termRange.location),
                                  query.index(query.startIndex, offsetBy: termRange.length))
    let foundTerm = String(query[startIndex..<endIndex])
    let urlEncoded = foundTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? foundTerm
    let dictURL = URL(string: String(format: "dict://%@", urlEncoded))!
    return [DisplayableContainer(name: foundTerm, content: definition as String, icon: icon, innerItem: dictURL)]
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    DictionarySerivce.historyStorage.append(value: source)
    NSWorkspace.shared.open(request)
  }
}
