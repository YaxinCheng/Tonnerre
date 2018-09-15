//
//  DelayedInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Interpreter provides delayed services.
 
 This is requested when no other interpreter can offer at least one service
 */
struct DelayedInterpreter: Interpreter {
  typealias LoaderType = DelayedServiceLoader
  let loader = DelayedServiceLoader()
  
  func wrap(_ rawData: [TonnerreService], withTokens tokens: [String]) -> [ServicePack] {
    return rawData.map { provider in
      if tokens.count - 1 >= provider.argLowerBound && tokens.count - 1 <= provider.argUpperBound {
        return provider.prepare(input: Array(tokens[1...])).map {
          ServicePack(provider: provider, service: $0)
        }
      } else if provider.argLowerBound > 0 {
        return [ServicePack(provider: provider)]
      } else { return [] }
      }.reduce([], +)
  }
}
