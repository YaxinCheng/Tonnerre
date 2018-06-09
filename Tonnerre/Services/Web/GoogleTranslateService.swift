//
//  GoogleTranslateService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol GoogleTranslate: TonnerreService {
}

extension GoogleTranslate {
  var keyword: String { return "translate" }
  var minTriggerNum: Int { return 1 }
  var hasPreview: Bool { return false }
  var acceptsInfiniteArguments: Bool { return true }
  var icon: NSImage { return #imageLiteral(resourceName: "Google_Translate") }
  var template: String { return "https://translate.google.%@/%@/%@/%@" }
  var name: String { return "Google Translate" }
  var content: String { return "Tranlsate your language" }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    NSWorkspace.shared.open(request)
  }
}

struct GoogleTranslateBasicService: GoogleTranslate {
  private let langueToEmoji: [String: String] = {
    let emojiFile = Bundle.main.path(forResource: "langueToEmoji", ofType: "plist")!
    return NSDictionary(contentsOfFile: emojiFile) as! [String: String]
  }()
  
  func prepare(input: [String]) -> [Displayable] {
    let queryContent = input.joined(separator: " ")
    guard let encodedContent = queryContent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return [] }
    let contentTemplate = "Translate \"\(queryContent)\" from %@ to %@"
    let autoToCurrent: [DisplayableContainer<URL>]
    if let currentLangCode = Locale.current.languageCode {
      let prefix = "🖥 ➡️ \(langueToEmoji[currentLangCode]!): "
      let regionCode = Locale.current.regionCode == "US" ? "com" : Locale.current.regionCode
      let translator = DisplayableContainer(name: prefix + queryContent, content: String(format: contentTemplate, "auto", currentLangCode), icon: icon, innerItem: URL(string: String(format: template, regionCode ?? "com", "#auto", currentLangCode, encodedContent)))
      autoToCurrent = [translator]
    } else { autoToCurrent = [] }
    return autoToCurrent
  }
}

struct GoogleTranslateAdvancedService: GoogleTranslate {
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
  
  func prepare(input: [String]) -> [Displayable] {
    var firstArg = input.first!.lowercased()
    let example = DisplayableContainer<Int>(name: "Example: translate en zh sentence", content: "Translate \"sentence\" from English to Chinese", icon: icon)
    var fromLangue: String = "..."
    var toLangue: String = "..."
    if input.count >= 1 {
      if firstArg == "zh" || firstArg == "zh-tw" { firstArg = "zh-cn" }
      if supportedLanguages.contains(firstArg) {
        fromLangue = NSLocale(localeIdentifier: firstArg).displayName(forKey: .identifier, value: firstArg) ?? "Error"
      } else if input.count == 1 { return [example] }
      else { return [] }
    }
    var secondArg: String = "..."
    if input.count >= 2 {
      secondArg = input[1].lowercased()
      if secondArg == "zh" { secondArg = "zh-tw" }
      if supportedLanguages.contains(secondArg) {
        toLangue = NSLocale(localeIdentifier: secondArg).displayName(forKey: .identifier, value: secondArg) ?? "Error"
      } else { return [] }
    }
    let query = input.count > 2 ? input[2...].joined(separator: " ") : "..."
    guard let encodedContent = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return [] }
    let contentTemplate = "Translate \"\(query)\" from %@ to %@"
    let regionCode = Locale.current.regionCode == "US" ? "com" : Locale.current.regionCode
    let prefix = "\(langueToEmoji[firstArg] ?? "...") ➡️ \(langueToEmoji[secondArg] ?? "..."): "
    let url = URL(string: String(format: template, regionCode ?? "com", "#" + firstArg, secondArg, encodedContent))
    let translator = DisplayableContainer(name: prefix + query, content: String(format: contentTemplate, fromLangue, toLangue), icon: icon, innerItem: url)
    return [translator]
  }
}
