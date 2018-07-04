//
//  TonnerreServiceLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreServiceLoader {
  private let normalServiceTrie: Trie<TonnerreService.Type>
  private let systemServiceTrie: Trie<TonnerreService.Type>
  private let interpreterServicesDict: [String: [TonnerreService.Type]]
  private var extendedServiceTrie: Trie<TonnerreExtendService>
  private let prioritizedServices: [TonnerreService]
  
  enum serviceType {
    case normal
    case system
    case interpreter
  }
  
  func autoComplete(key: String, type: serviceType = .normal, includeExtra: Bool = true) -> [TonnerreService] {
    if type == .normal {
      let fetchedServices = normalServiceTrie.find(value: key).filter { !$0.isDisabled || !includeExtra }.map { $0.init() }
      let prioritized = includeExtra ? (prioritizedServices) : []
      let extended = extendedServiceTrie.find(value: key).filter { !$0.isDisabled || !includeExtra }
      return fetchedServices + prioritized + extended
    } else if type == .system {
      return systemServiceTrie.find(value: key).filter { !$0.isDisabled || !includeExtra } .map { $0.init() }
    } else if type == .interpreter {
      return (interpreterServicesDict[key] ?? []).map { $0.init() }
    } else { return [] }
  }
  
  init() {
    prioritizedServices = [LaunchService(), CalculationService(), URLService(), CurrencyService()]
    let normalServices: [TonnerreService.Type] = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, GoogleMapService.self, TrashEmptyService.self, DictionarySerivce.self, GoogleTranslateService.self, BingSearch.self, DuckDuckGoSearch.self, ScreenSaverService.self, LockService.self]
    let systemServices: [TonnerreService.Type] = [ApplicationService.self, VolumeService.self]
    let interpreterServices: [TonnerreService.Type] = [ServicesService.self, ReloadService.self/*, DefaultService.self*/]
    normalServiceTrie = Trie(values: normalServices) { $0.keyword }
    systemServiceTrie = Trie(values: systemServices) { $0.keyword }
    interpreterServicesDict = Dictionary(interpreterServices.map { ($0.keyword, [$0]) }, uniquingKeysWith: +)
    extendedServiceTrie = Trie(values: GeneralWebService.load()) { $0.keyword }
  }
  
  mutating func reload() {
    extendedServiceTrie = Trie(values: GeneralWebService.load()) { $0.keyword }
  }
}
