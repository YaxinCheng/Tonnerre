//
//  GoogleTranslateService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct GoogleTranslateService: BuiltInProvider, HistoryProtocol {  
  let defaultKeyword: String = "translate"
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "Google_Translate")
  let template: String = "https://translate.google.%@/#view=home&op=translate&sl=%@&tl=%@&text=%@"
  let name: String = "Google Translate"
  let content: String = "Tranlsate your language"
  let historyLimit: Int = 8
  let identifier: String = "GoogleTranslateService"
  
  private static let supportedLanguages: Set<String> = {
    let codeFile = Bundle.main.path(forResource: "langueCodes", ofType: "plist")!
    return Set<String>(NSArray(contentsOfFile: codeFile) as! [String])
  }()
  private static let langueToEmoji: [String: String] = {
    let emojiFile = Bundle.main.path(forResource: "langueToEmoji", ofType: "plist")!
    return NSDictionary(contentsOfFile: emojiFile) as! [String: String]
  }()

  private func generateAuto(query: String) -> [DisplayContainer<URL>] {
    guard let encodedContent = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return [] }
    let contentTemplate = "Translate \"\(query)\" from %@ to %@"
    if let currentLangCode = Locale.current.languageCode {
      let prefix = "🖥 ➡️ \(type(of: self).langueToEmoji[currentLangCode]!): "
      let regionCode = Locale.current.regionCode == "US" ? "com" : Locale.current.regionCode
      let translator = DisplayContainer(name: prefix + query, content: String(format: contentTemplate, "auto", currentLangCode), icon: icon, innerItem: URL(string: String(format: template, regionCode ?? "com", "auto", currentLangCode, encodedContent)), placeholder: "from to content")
      return [translator]
    } else { return [] }
  }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    var firstArg = input.first!.lowercased()
    let example = DisplayContainer<Int>(name: "Example: translate en zh sentence", content: "Translate \"sentence\" from English to Chinese", icon: icon)
    let rawQuery = input.joined(separator: " ")
    let autoTranslator = generateAuto(query: rawQuery)
    let history = histories().map { $0.components(separatedBy: "/") }.compactMap { formContents(query: rawQuery, fromLangue: $0[0], toLangue: $0[1]) }
    if input.count >= 1 {
      if firstArg.starts(with: "zh") { firstArg = "zh-CN" }
      if !type(of: self).supportedLanguages.contains(firstArg) {
        return autoTranslator + history + [example]
      }
    }
    var secondArg: String = "..."
    if input.count >= 2 {
      secondArg = input[1].lowercased()
      if secondArg == "zh" || secondArg == "zh-tw" { secondArg = "zh-TW" }
      else if secondArg == "zh-cn" { secondArg = "zh-CN" }
      if secondArg.count >= 2 && !type(of: self).supportedLanguages.contains(secondArg) { return autoTranslator + history + [example] }
    }
    let query = input.count > 2 ? input[2...].joined(separator: " ") : "..."
    guard let _ = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return autoTranslator + history }
    let translator = formContents(query: query, fromLangue: firstArg, toLangue: secondArg)!
    return [translator] + autoTranslator + history
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    guard
      let item = service as? DisplayContainer<URL>,
      let request = item.innerItem
    else { return }
    if case .string(let requestedLangues)? = item.config,
      !requestedLangues.starts(with: "auto") {
      appendHistory(query: requestedLangues, unique: true)
    }
    NSWorkspace.shared.open(request)
  }
  
  private func formContents(query: String, fromLangue: String, toLangue: String) -> DisplayContainer<URL>? {
    guard let encodedContent = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
    let contentTemplate = "Translate \"\(query)\" from %@ to %@"
    let regionCode = Locale.current.regionCode == "US" ? "com" : Locale.current.regionCode
    let prefix = "\(type(of: self).langueToEmoji[fromLangue] ?? "...") ➡️ \(type(of: self).langueToEmoji[toLangue] ?? "..."): "
    let url = URL(string: String(format: template, regionCode ?? "com", fromLangue, toLangue, encodedContent))
    let localizedFromLangue = NSLocale(localeIdentifier: fromLangue).displayName(forKey: .identifier, value: fromLangue) ?? "..."
    let localizedToLangue = NSLocale(localeIdentifier: toLangue).displayName(forKey: .identifier, value: toLangue) ?? "..."
    return DisplayContainer(name: prefix + query, content: String(format: contentTemplate, localizedFromLangue, localizedToLangue), icon: icon, innerItem: url, config: .string("\(fromLangue)/\(toLangue)"))
  }
}
