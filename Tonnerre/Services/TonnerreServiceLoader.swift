//
//  TonnerreServiceLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreServiceLoader {
  private lazy var trie: Trie = {
    return Trie(values: keywords)
  }()
  
  private let serviceTypes: [TonnerreService.Type]
  
  lazy var services: [String: [TonnerreService]] = {// keyword : instance
    let loadedServices = serviceTypes.map { (type) -> (String, [TonnerreService]) in
      let instance = type.init()
      return (instance.keyword, [instance])
    }
    let generalWebServices: [(String, [TonnerreService])] = GeneralWebService.load().map { ($0.keyword, [$0]) }
    return Dictionary(loadedServices + generalWebServices, uniquingKeysWith: +)
  }()
  
  lazy var keywords: Set<String> = {
    return Set(serviceTypes.map { $0.init().keyword } + GeneralWebService.load().map { $0.keyword } )
  }()
  
  mutating func autoComplete(key: String) -> [TonnerreService] {
    return trie.find(value: key).compactMap({ services[$0] }).reduce([], +)
  }
  
  mutating func exactMatch(key: String) -> [TonnerreService] {
    guard keywords.contains(key) else { return [] }
    return services[key] ?? []
  }
  
  init() {
    serviceTypes = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, AppleMapService.self]
  }
}
