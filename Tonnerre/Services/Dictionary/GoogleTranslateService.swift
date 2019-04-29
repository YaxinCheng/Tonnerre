//
//  GoogleTranslateService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

/// Supports config GoogleTranslateService
fileprivate struct TranslateSupports {
  private static let langueToEmoji: [String: String] = {
    let content: Result<[String:String], Error> = PropertyListSerialization.read(fileName: "langueToEmoji")
    switch content {
    case .success(let emojiFile): return emojiFile
    case .failure(let error):
      Logger.error(file: GoogleTranslateService.self, "Reading langueToEmoji Error: %{PUBLIC}@", error.localizedDescription)
      return [:]
    }
  }()
  
  private static let langueAlias = ["zh": "zh-CN", "tw": "zh-TW", "zh-tw": "zh-TW", "zh-cn": "zh-CN"]
  private let _ARROW_KEY = "➡️"
  let _AUTO_LANG_CODE = "auto"
  let _PLACE_HOLDER = "content"
  
  func generateItem(fromLangue: String, toLangue: String, content: String) -> (name: String, content: String)? {
    let fromLangue = TranslateSupports.langueAlias[fromLangue] ?? fromLangue
    let toLangue = TranslateSupports.langueAlias[toLangue] ?? toLangue
    guard
      let fromEmoji = TranslateSupports.langueToEmoji[fromLangue],
      let toEmoji = TranslateSupports.langueToEmoji[toLangue]
    else { return nil }
    let name = "\(fromEmoji) \(_ARROW_KEY) \(toEmoji): \(content)"
    let content = "Translate \"\(content)\" from \(fetchLangueName(languageCode: fromLangue)) to \(fetchLangueName(languageCode: toLangue))"
    return (name, content)
  }
  
  private func fetchLangueName(languageCode: String) -> String {
    return NSLocale(localeIdentifier: languageCode).displayName(forKey: .identifier, value: languageCode) ?? "auto"
  }
}

private protocol TranslateService: WebService, HistoryProtocol {}
extension TranslateService {
  var defaultKeyword: String { return "translate" }
  var argUpperBound: Int { return .max }
  var icon: NSImage { return #imageLiteral(resourceName: "Google_Translate") }
  var name: String { return "Google Translate" }
  var identifier: String { return "GoogleTranslateService" }
  var contentTemplate: String { return "Translate \"%@\" to %@" }
  var historyLimit: Int { return 8 }
  
  func parse(suggestionData: Data?) -> [String] {
    return []
  }
}

struct GoogleTranslateAutoService: TranslateService {
  let argLowerBound: Int = 1
  private let supports = TranslateSupports()
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    guard
      let currentLangue = Locale.current.languageCode,
      let (name, content) = supports.generateItem(fromLangue: supports._AUTO_LANG_CODE, toLangue: currentLangue, content: input.joined(separator: " "))
    else { return [self] }
    return [DisplayContainer(name: name,
                             content: content,
                             icon: icon,
                             innerItem: encodedURL(input: [supports._AUTO_LANG_CODE, currentLangue] + input),
                             placeholder: supports._PLACE_HOLDER)]
  }
  
  func supply(withInput input: [String], callback: @escaping ([DisplayItem]) -> Void) {
    let query = input.joined(separator: " ")
    let historyQueries: [DisplayItem] = histories()
      .map { $0.components(separatedBy: "/") }
      .compactMap {
      guard
        let (name, content) = supports.generateItem(fromLangue: $0[0], toLangue: $0[1], content: query)
      else { return nil }
      return DisplayContainer(name: name, content: content, icon: icon,
                              innerItem: encodedURL(input: [$0[0], $0[1]] + input),
                              placeholder: supports._PLACE_HOLDER)
    }
    callback(historyQueries)
  }
}

struct GoogleTranslateService: TranslateService {
  let argLowerBound: Int = 3
  private let supports = TranslateSupports()
  
  func parse(suggestionData: Data?) -> [String] {
    return []
  }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    let (fromLangue, toLangue) = (input[0], input[1])
    let query = input[2...].joined(separator: " ")
    guard
      let (name, content) = supports.generateItem(fromLangue: fromLangue, toLangue: toLangue, content: query)
    else { return [] }
    if !query.isEmpty && fromLangue != supports._AUTO_LANG_CODE {
      appendHistory(query: "\(fromLangue)/\(toLangue)", unique: true)
    }
    return [DisplayContainer(name: name, content: content, icon: icon,
                             innerItem: encodedURL(input: input),
                             placeholder: supports._PLACE_HOLDER)]
  }
}
