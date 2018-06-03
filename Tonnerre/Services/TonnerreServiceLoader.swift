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
  
  private let serviceTypes: [TonnerreService.Type] = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self]
  
  lazy var services: [String: TonnerreService] = {
    return Dictionary(uniqueKeysWithValues: serviceTypes.map ({ (type) -> (String, TonnerreService) in
      let instance = type.init()
      return (instance.keyword, instance)
    }))
  }()
  
  lazy var keywords: Set<String> = {
    return Set(serviceTypes.map({ $0.init().keyword }))
  }()
  
  mutating func autoComplete(key: String) -> [TonnerreService] {
    return trie.find(value: key).compactMap({ services[$0] })
  }
  
  mutating func exactMatch(key: String) -> [TonnerreService] {
    let matchedKeys = keywords.filter { $0 == key }
    return matchedKeys.compactMap { services[$0] }
  }
}
