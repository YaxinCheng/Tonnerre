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
  var cachedProviders: Array<BuiltInProvider> = []
  
  typealias ServiceType = BuiltInProvider
  /**
   A trie that contains all general services
  */
  private let providerTrie: Trie<BuiltInProvider.Type>
  
  func _find(keyword: String) -> [BuiltInProvider] {
    let fetchedServices = providerTrie.find(value: keyword.lowercased())
      .filter { !DisableManager.shared.isDisabled(builtinProvider: $0) }
      .map { $0.init() }
    return fetchedServices
  }
  
  init() {
    let GeneralProviders: [BuiltInProvider.Type] = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, GoogleMapService.self, DictionarySerivce.self, GoogleTranslateService.self, BingSearch.self, DuckDuckGoSearch.self, SafariBMService.self ,ChromeBMService.self, ClipboardService.self]
    
    let saveToSettings: ([BuiltInProvider.Type]) -> () = { providers in
      DispatchQueue.global(qos: .background).async {
        let userDefault = UserDefaults.shared
        let settings = providers.map { $0.init() }
          .map { [$0.keyword, $0.name, $0.content, $0.id] }
        userDefault.set(settings, forKey: .generalProviders)
      }
    }
    saveToSettings(GeneralProviders)
    
    providerTrie = Trie(values: GeneralProviders + [SettingService.self]) {
      BuiltInProviderMap.extractKeyword(from: $0)
    }
    
    let clipboardAvailable = !DisableManager.shared.isDisabled(builtinProvider: ClipboardService.self)
    if clipboardAvailable {
      ClipboardService.monitor.start()
    }
  }

}
