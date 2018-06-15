//
//  GoogleTranslateService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct GoogleTranslateService: TonnerreService {
  static let keyword: String = "translate"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "Google_Translate")
  let template: String = "https://translate.google.%@/m/translate%@/%@/%@"
  let name: String = "Google Translate"
  let content: String = "Tranlsate your language"
  private static let historyStorage = QueryStack<URL>(size: 5)
  
  private let supportedLanguages: Set<String>
  private let langueToEmoji: [String: String]
  init() {
    supportedLanguages = {
      let codeFile = Bundle.main.path(forResource: "langueCodes", ofType: "plist")!
      return Set<String>(NSArray(contentsOfFile: codeFile) as! [String])
    }()
    langueToEmoji = {
      let emojiFile = Bundle.main.path(forResource: "langueToEmoji", ofType: "plist")!
      return NSDictionary(contentsOfFile: emojiFile) as! [String: String]
    }()
  }
  
  private func generateAuto(query: String) -> [DisplayableContainer<URL>] {
    guard let encodedContent = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return [] }
    let contentTemplate = "Translate \"\(query)\" from %@ to %@"
    if let currentLangCode = Locale.current.languageCode {
      let prefix = "🖥 ➡️ \(langueToEmoji[currentLangCode]!): "
      let regionCode = Locale.current.regionCode == "US" ? "com" : Locale.current.regionCode
      let translator = DisplayableContainer(name: prefix + query, content: String(format: contentTemplate, "auto", currentLangCode), icon: icon, innerItem: URL(string: String(format: template, regionCode ?? "com", "#auto", currentLangCode, encodedContent)))
      return [translator]
    } else { return [] }
  }
  
  func prepare(input: [String]) -> [Displayable] {
    var firstArg = input.first!.lowercased()
    let example = DisplayableContainer<Int>(name: "Advanced Example: translate en zh sentence", content: "Translate \"sentence\" from English to Chinese", icon: icon)
    let autoTranslator = generateAuto(query: input.joined(separator: " "))
    let histories = reuseHistory(forQuery: input.joined(separator: " "))
    if input.count >= 1 {
      if firstArg.starts(with: "zh") { firstArg = "zh-CN" }
      if !supportedLanguages.contains(firstArg) {
        if histories.isEmpty { return autoTranslator + [example] }
        else { return autoTranslator + histories }
      }
    }
    var secondArg: String = "..."
    if input.count >= 2 {
      secondArg = input[1].lowercased()
      if secondArg == "zh" || secondArg == "zh-tw" { secondArg = "zh-TW" }
      else if secondArg == "zh-cn" { secondArg = "zh-CN" }
      if secondArg.count >= 2 && !supportedLanguages.contains(secondArg) { return autoTranslator + histories }
    }
    let query = input.count > 2 ? input[2...].joined(separator: " ") : "..."
    guard let _ = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return autoTranslator + histories }
    let translator = formContents(query: query, fromLangue: firstArg, toLangue: secondArg)!
    return [translator] + autoTranslator + histories
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    let urlComponents = request.absoluteString.components(separatedBy: "/")
    let isAuto = urlComponents[4] == "translate#auto"
    let existed = GoogleTranslateService.historyStorage.contains {
      let components = $0.absoluteString.components(separatedBy: "/")
      return components[4] == urlComponents[4] && components[5] == urlComponents[5]
    }
    if !isAuto && !existed {
      GoogleTranslateService.historyStorage.append(value: request)
    }
    NSWorkspace.shared.open(request)
  }
  
  private func reuseHistory(forQuery: String) -> [DisplayableContainer<URL>] {
    let urlExtractor: (URL)->(String, String) = {
      let components = $0.absoluteString.components(separatedBy: "/")
      return (components[4].replacingOccurrences(of: "translate#", with: ""), components[5])
    }
    let components = GoogleTranslateService.historyStorage.values().map(urlExtractor)
    return components.compactMap { formContents(query: forQuery, fromLangue: $0.0, toLangue: $0.1) }
  }
  
  private func formContents(query: String, fromLangue: String, toLangue: String) -> DisplayableContainer<URL>? {
    guard let encodedContent = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return nil }
    let contentTemplate = "Translate \"\(query)\" from %@ to %@"
    let regionCode = Locale.current.regionCode == "US" ? "com" : Locale.current.regionCode
    let prefix = "\(langueToEmoji[fromLangue] ?? "...") ➡️ \(langueToEmoji[toLangue] ?? "..."): "
    let url = URL(string: String(format: template, regionCode ?? "com", "#" + fromLangue, toLangue, encodedContent))
    let localizedFromLangue = NSLocale(localeIdentifier: fromLangue).displayName(forKey: .identifier, value: fromLangue) ?? "..."
    let localizedToLangue = NSLocale(localeIdentifier: toLangue).displayName(forKey: .identifier, value: toLangue) ?? "..."
    return DisplayableContainer(name: prefix + query, content: String(format: contentTemplate, localizedFromLangue, localizedToLangue), icon: icon, innerItem: url)
  }
}
