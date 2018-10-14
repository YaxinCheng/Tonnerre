//
//  DictionaryService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import CoreServices
import Foundation

struct DictionarySerivce: TonnerreService {
  let icon: NSImage = .dictionary
  let content: String = "Find definition for word in dictionary"
  let name: String = "Define words..."
  static let keyword: String = "define"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  private let spellChecker = NSSpellChecker.shared
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard input.count > 0, !input[0].isEmpty else { return [self] }
    let text = input.joined(separator: " ")
    let suggestions = spellChecker.completions(forPartialWordRange: NSRange(text.startIndex..., in: text), in: text, language: nil, inSpellDocumentWithTag: NSSpellChecker.uniqueSpellDocumentTag()) ?? []
    let wrappedSuggestions = (suggestions + [text]).compactMap(wrap)
    return wrappedSuggestions
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let request = source as? DisplayableContainer<URL>, let url = request.innerItem else { return }
    NSWorkspace.shared.open(url)
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
  
  private func wrap(_ query: String) -> DisplayableContainer<URL>? {
    guard let (foundTerm, definition) = define(query) else { return nil }
    let urlEncoded = foundTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? foundTerm
    let dictURL = URL(string: String(format: "dict://%@", urlEncoded))!
    return DisplayableContainer(name: foundTerm, content: definition, icon: icon, priority: priority, innerItem: dictURL)
  }
}
