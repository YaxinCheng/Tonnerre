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
  
  lazy var services: [String: TonnerreService] = {// keyword : instance
    return Dictionary(uniqueKeysWithValues: serviceTypes.map { (type) -> (String, TonnerreService) in
      let instance = type.init()
      return (instance.keyword, instance)
    } + GeneralWebService.load().map { ($0.keyword, $0) } )
  }()
  
  lazy var keywords: Set<String> = {
    return Set(serviceTypes.map { $0.init().keyword } + GeneralWebService.load().map { $0.keyword } )
  }()
  
  mutating func autoComplete(key: String) -> [TonnerreService] {
    return trie.find(value: key).compactMap({ services[$0] })
  }
  
  mutating func exactMatch(key: String) -> [TonnerreService] {
    let matchedKeys = keywords.filter { $0 == key }
    return matchedKeys.compactMap { services[$0] }
  }
  
  init() {
    serviceTypes = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self]
  }
}
