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
  private var extendedServiceTrie: Trie<TonnerreService.Type>
  private let prioritizedServices: [TonnerreService]
  
  enum serviceType {
    case normal
    case system
    case interpreter
  }
  
  func autoComplete(key: String, type: serviceType = .normal, includeExtra: Bool = true) -> [TonnerreService] {
    if type == .normal {
      let fetchedServices: [TonnerreService] = (normalServiceTrie.find(value: key) + extendedServiceTrie.find(value: key))
        .filter { !$0.isDisabled || !includeExtra }
        .map {
          if let ext = $0 as? ExtendedWebService.Type {
            return ext.init() as! TonnerreService
          }
          return $0.init()
      }
      let prioritized = includeExtra ? (prioritizedServices) : []
      return fetchedServices + prioritized
    } else if type == .system {
      return systemServiceTrie.find(value: key).filter { !$0.isDisabled || !includeExtra } .map { $0.init() }
    } else if type == .interpreter {
      return (interpreterServicesDict[key] ?? []).map { $0.init() }
    } else { return [] }
  }
  
  init() {
    prioritizedServices = [LaunchService(), CalculationService(), URLService(), CurrencyService()]
    let normalServices: [TonnerreService.Type] = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, GoogleMapService.self, TrashEmptyService.self, DictionarySerivce.self, GoogleTranslateService.self, BingSearch.self, DuckDuckGoSearch.self]
    let systemServices: [TonnerreService.Type] = [ApplicationService.self, VolumeService.self]
    let interpreterServices: [TonnerreService.Type] = [ServicesService.self, ReloadService.self/*, DefaultService.self*/]
    normalServiceTrie = Trie(values: normalServices) { $0.keyword }
    systemServiceTrie = Trie(values: systemServices) { $0.keyword }
    interpreterServicesDict = Dictionary(interpreterServices.map { ($0.keyword, [$0]) }, uniquingKeysWith: +)
    let extServiceLoader = ExtWebServicesLoader()
    extendedServiceTrie = Trie(values: extServiceLoader.load()) { $0.keyword }
  }
  
  mutating func reload() {
    let extendedServices = extendedServiceTrie.find(value: "")
    for service in extendedServices {
      objc_disposeClassPair(service as! AnyClass)
    }
    let extServiceLoader = ExtWebServicesLoader()
    extendedServiceTrie = Trie(values: extServiceLoader.load()) { $0.keyword }
  }
}
