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
  
  func _find(keyword: String) -> [TonnerreService] {
    return [GoogleSearch(suggestion: true)]
  }
}
