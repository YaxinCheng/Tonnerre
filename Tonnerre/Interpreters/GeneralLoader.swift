//
//  GeneralLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class GeneralLoader: ServiceLoader {
  var cachedKey: String = ""
  var cachedProviders: Array<TonnerreService> = []
  
  typealias ServiceType = TonnerreService
  /**
   A trie that contains all general services
  */
  private let providerTrie: Trie<TonnerreService.Type>
  
  func _find(keyword: String) -> [TonnerreService] {
    let fetchedServices = providerTrie.find(value: keyword)
      .filter { !$0.isDisabled }
      .map { $0.init() }
    return fetchedServices
  }
  
  init() {
    let GeneralProviders: [TonnerreService.Type] = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, GoogleMapService.self, DictionarySerivce.self, GoogleTranslateService.self, BingSearch.self, DuckDuckGoSearch.self, SafariBMService.self, ChromeBMService.self, TerminalService.self, ClipboardService.self]
    
    let saveToSettings: ([TonnerreService.Type]) -> () = { providers in
      DispatchQueue.global(qos: .background).async {
        let userDefault = UserDefaults.shared
        let settings = providers.map { $0.init() }
          .map { [type(of: $0).keyword, $0.name, $0.content, type(of: $0).settingKey] }
        userDefault.set(settings, forKey: .generalProviders)
      }
    }
    saveToSettings(GeneralProviders)
    
    providerTrie = Trie(values: GeneralProviders + [SettingService.self]) { $0.keyword }
    if ClipboardService.isDisabled == false {
      ClipboardService.monitor.start()
    }
  }

}
