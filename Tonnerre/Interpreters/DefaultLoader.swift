//
//  DefaultLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-16.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class DefaultLoader: ServiceLoader {
  typealias ServiceType = TonnerreService
  var cachedKey: String = ""
  var cachedProviders: Array<TonnerreService> = []
  let defaultServices: [String: TonnerreService.Type]
  
  init() {
    defaultServices = [
      "FileNameSearchService": FileNameSearchService.self,
      "FileContentSearchService": FileContentSearchService.self,
      "GoogleSearch": GoogleSearch.self,
      "BingSearch": BingSearch.self,
      "DuckDuckGoSearch": DuckDuckGoSearch.self
    ]
  }
  
  func _find(keyword: String) -> [TonnerreService] {
    let userDefault = UserDefaults.shared
    guard
      let serviceKeys: [String] = userDefault.array(forKey: .defaultServices)
    else { return [GoogleSearch()] }
    let loadedServices = serviceKeys.compactMap { defaultServices[$0] }.map { $0.init() }
    return loadedServices ?? [GoogleSearch()]
  }
}
