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
  let icon: NSImage = .dictionary
  let content: String = "Find definition for word in dictionary"
  let name: String = "Define words..."
  static let keyword: String = "define"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  private let spellChecker: NSSpellChecker
  
  init() {
    spellChecker = .shared
    spellChecker.automaticallyIdentifiesLanguages = true
  }
  
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    guard input.count > 0, !input[0].isEmpty else { return [self] }
    let text = input.joined(separator: " ")
    let suggestions = spellChecker.completions(forPartialWordRange: NSRange(text.startIndex..., in: text), in: text, language: nil, inSpellDocumentWithTag: NSSpellChecker.uniqueSpellDocumentTag()) ?? []
    let filteredSuggestiosn = suggestions.filter { $0.lowercased() != text }
    return [wrapQuery(text)] + filteredSuggestiosn.compactMap(wrap)
  }
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    guard let request = service as? DisplayableContainer<URL>, let url = request.innerItem else { return }
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
  
  private func wrapQuery(_ query: String) -> DisplayableContainer<URL> {
    let (headWord, content): (String, String)
    let definitionView: NSView?
    if let (foundTerm, definition) = define(query) {
      headWord = foundTerm
      content = definition
      definitionView = buildView(with: definition)
    } else {
      headWord = query
      content = "Cannot find definition for \"\(query)\""
      definitionView = nil
    }
    let urlEncoded = headWord.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? headWord
    let dictURL = URL(string: String(format: "dict://%@", urlEncoded))!
    return DisplayableContainer(name: headWord, content: content, icon: icon, priority: priority, innerItem: dictURL, placeholder: "", extraContent: definitionView)
  }
  
  private func wrap(_ query: String) -> DisplayableContainer<URL>? {
    guard let (foundTerm, definition) = define(query) else { return nil }
    let urlEncoded = foundTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? foundTerm
    let dictURL = URL(string: String(format: "dict://%@", urlEncoded))!
    let viewController = buildView(with: definition)
    return DisplayableContainer(name: foundTerm, content: definition, icon: icon, priority: priority, innerItem: dictURL, extraContent: viewController)
  }
  
  private func buildView(with definition: String) -> NSView {
    let targetView: NSView
    let textView: NSTextView
    if #available(OSX 10.14, *) {
      targetView = NSTextView.scrollablePlainDocumentContentTextView()
      textView = (targetView as! NSScrollView).documentView as! NSTextView
    } else {
      textView = NSTextView()
      targetView = textView
    }
    textView.drawsBackground = false
    textView.string = definition
    textView.isEditable = false
    textView.font = .systemFont(ofSize: 17)
    return targetView
  }
}
