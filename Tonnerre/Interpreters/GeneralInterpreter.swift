//
//  GeneralInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Interpreter provides general built-in services 
 */
struct GeneralInterpreter<T: ServiceLoader>: Interpreter where T.ServiceType == BuiltInProvider {
  typealias LoaderType = T
  let loader: T
  func wrap(_ rawData: [BuiltInProvider], withTokens tokens: [String]) -> [ServicePack] {
    return rawData.map { provider in
      let keyword = provider.keyword
      if provider is DeferedServiceProtocol && keyword != tokens.first { return [] }
      if tokens.count - 1 > provider.argUpperBound { return [] }
      else if tokens.count - 1 >= provider.argLowerBound  {
        return provider.prepare(withInput: Array(tokens[1...])).map {
          ServicePack(provider: provider, service: $0)
        }
      } else if provider.argLowerBound > 0 {
        return [ServicePack(provider: provider)]
      } else { return [] }
    }.reduce([], +)
  }
  
  init(loader: T) {
    self.loader = loader
  }
}
