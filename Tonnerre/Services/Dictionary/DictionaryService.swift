//
//  DictionaryService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import CoreServices
import Cocoa

struct DictionarySerivce: TonnerreService, HistoryProtocol {
  let icon: NSImage = #imageLiteral(resourceName: "dictionary")
  let content: String = "Find definition for word in dictionary"
  let name: String = "Define words..."
  static let keyword: String = "define"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let historyLimit: Int = 8
  let identifier: String = "DictionaryService"
  
  func prepare(input: [String]) -> [Displayable] {
    guard input.count > 0, !input[0].isEmpty else {
      let history = histories()
      return [self] + reuse(history: history)
    }
    let query = input.joined(separator: " ")
    guard let (foundTerm, definition) = define(query) else {
      return [DisplayableContainer<URL>(name: query, content: "\"\(query)\" is not found", icon: icon)]
    }
    let urlEncoded = foundTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? foundTerm
    let dictURL = URL(string: String(format: "dict://%@", urlEncoded))!
    return [DisplayableContainer(name: foundTerm, content: definition as String, icon: icon, innerItem: dictURL)]
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = source as? DisplayableContainer<URL>, let url = request.innerItem else { return }
    appendHistory(query: request.name)
    NSWorkspace.shared.open(url)
  }
  
  func reuse(history: [String]) -> [Displayable] {
    let termsAndDefs = history.compactMap { define($0) }
    return termsAndDefs.map {
      let urlEncoded = $0.0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? $0.0
      let dictURL = URL(string: String(format: "dict://%@", urlEncoded))!
      return DisplayableContainer(name: $0.0, content: $0.1, icon: icon, innerItem: dictURL)
    }
  }
  
  private func define(_ query: String) -> (String, String)? {
    let termRange = DCSGetTermRangeInString(nil, query as CFString, 0)
    guard
      termRange.location != kCFNotFound,
      let definition = DCSCopyTextDefinition(nil, query as CFString, termRange)?.takeRetainedValue()
    else { return nil }
    let startIndex = query.index(query.startIndex, offsetBy: termRange.location)
    let endIndex = query.index(startIndex, offsetBy: termRange.length)
    let foundTerm = String(query[startIndex ..< endIndex])
    return (foundTerm, String(definition))
  }
}
