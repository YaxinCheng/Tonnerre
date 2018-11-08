//
//  PrioriInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Interpreter provides all services that require no keyword
 */
struct InstantInterpreter<T: ServiceLoader>: Interpreter where T.ServiceType == BuiltInProvider {
  typealias LoaderType = T
  let loader: T
  
  func wrap(_ rawData: [BuiltInProvider], withTokens tokens: [String]) -> [ServicePack] {
    return rawData.map { provider in
      if tokens.count >= provider.argLowerBound && tokens.count <= provider.argUpperBound {
        return provider.prepare(withInput: tokens).map { ServicePack(provider: provider, service: $0) }
      } else {
        return []
      }
    }.reduce([], +)
  }
  
  func clearCache() {
    loader.cachedProviders = []
    loader.cachedKey = ""
  }
  
  init(loader: T) {
    self.loader = loader
  }
}
