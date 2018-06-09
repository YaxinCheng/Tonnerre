//
//  GoogleTranslateService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct GoogleTranslateService: TonnerreService {
  let keyword: String = "translate"
  let minTriggerNum: Int = 1
  let hasPreview: Bool = false
  let acceptsInfiniteArguments: Bool = true
  let icon: NSImage = #imageLiteral(resourceName: "Google_Translate")
  let template: String = "https://translate.google.%@/%@/%@/%@"
  let name: String = "Google Translate"
  let content: String = "Tranlsate your language"
//  private let languageCodesTrie: Trie
  
  func prepare(input: [String]) -> [Displayable] {
    let queryContent = input.joined(separator: " ")
    guard let encodedContent = queryContent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return [] }
    let contentTemplate = "Translate \"\(queryContent)\" from %@ to %@"
    let autoToCurrent: [DisplayableContainer<URL>]
    if let currentLangCode = Locale.current.languageCode {
      let regionCode = Locale.current.regionCode == "US" ? "com" : Locale.current.regionCode
      let translator = DisplayableContainer(name: queryContent, content: String(format: contentTemplate, "auto", currentLangCode), icon: icon, innerItem: URL(string: String(format: template, regionCode ?? "com", "#auto", currentLangCode, encodedContent)))
      autoToCurrent = [translator]
    } else { autoToCurrent = [] }
    
    return autoToCurrent
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    NSWorkspace.shared.open(request)
  }
  
  init() {
//    languageCodesTrie = Trie(values: Set(Locale.isoLanguageCodes))
  }
}
