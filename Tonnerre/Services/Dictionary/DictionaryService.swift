//
//  DictionaryService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import CoreServices
import Cocoa

struct DictionarySerivce: BuiltInProvider {
  let icon: NSImage = .dictionary
  let content: String = "Find definition for word in dictionary"
  let name: String = "Define words..."
  let defaultKeyword: String = "define"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  private let spellChecker: NSSpellChecker
  
  init() {
    spellChecker = .shared
    spellChecker.automaticallyIdentifiesLanguages = true
  }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    guard input.count > 0, !input[0].isEmpty else { return [self] }
    let text = input.joined(separator: " ")
    let notFoundItem = DisplayContainer(name: text, content: "Cannot find definition for \"\(text)\"", icon: icon, innerItem: URL(string: "dict://\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
    return [buildService(basedOn: text, defaultService: notFoundItem)!]
  }
  
  func supply(withInput input: [String], callback: @escaping ([DisplayItem])->Void) {
    guard input.count > 0, !input[0].isEmpty else {
      callback([])
      return
    }
    let text = input.joined(separator: " ")
    let suggestions = spellChecker.completions(forPartialWordRange: NSRange(text.startIndex..., in: text), in: text, language: nil, inSpellDocumentWithTag: NSSpellChecker.uniqueSpellDocumentTag()) ?? []
    let filteredSuggestions = suggestions.filter { $0.caseInsensitiveCompare(text) != .orderedSame }
    callback(filteredSuggestions.compactMap { buildService(basedOn: $0, defaultService: nil) } )
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    guard let request = service as? DisplayContainer<URL>, let url = request.innerItem else { return }
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
  
  private func buildService(basedOn query: String,
                    defaultService: @autoclosure ()->DisplayContainer<URL>?) -> DisplayContainer<URL>?
  {
    guard
      let (foundTerm, definition) = define(query),
      foundTerm.caseInsensitiveCompare(query) == .orderedSame
    else { return defaultService() }
    let headWord = foundTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? foundTerm
    let dictURL = URL(string: String(format: "dict://%@", headWord))!
    return DisplayContainer(name: foundTerm, content: definition, icon: icon, innerItem: dictURL)
  }
}
