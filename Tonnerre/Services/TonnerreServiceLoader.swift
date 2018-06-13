//
//  TonnerreServiceLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

class TonnerreServiceLoader {
  private let normalServiceTrie: Trie<TonnerreService.Type>
  private let systemServiceTrie: Trie<TonnerreService.Type>
  private var extendedServiceTrie: Trie<TonnerreExtendService>
  private let prioritizedServices: [TonnerreService]
  
  enum serviceType {
    case normal
    case system
  }
  
  func autoComplete(key: String, type: serviceType = .normal) -> [TonnerreService] {
    if type == .normal {
      let fetchedServices = normalServiceTrie.find(value: key)
      return fetchedServices.map { $0.init() }
        + extendedServiceTrie.find(value: key) + prioritizedServices
    } else if type == .system {
      let fetchedServices = systemServiceTrie.find(value: key)
      return fetchedServices.map { $0.init() }
    } else { return [] }
  }
  
  init() {
    prioritizedServices = [LaunchService(), CalculationService(), URLService(), CurrencyService()]
    let normalServices: [TonnerreService.Type] = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, GoogleMapService.self, TrashEmptyService.self, DictionarySerivce.self, GoogleTranslateService.self]
    let systemServices: [TonnerreService.Type] = [ApplicationService.self, VolumeService.self]
    normalServiceTrie = Trie(values: normalServices) { $0.keyword }
    systemServiceTrie = Trie(values: systemServices) { $0.keyword }
    extendedServiceTrie = Trie(values: GeneralWebService.load()) { $0.keyword }
  }
  
  func reloadServices() {
    let extendedWebService = GeneralWebService.load()
    extendedServiceTrie = Trie(values: extendedWebService) { $0.keyword }
  }
}
