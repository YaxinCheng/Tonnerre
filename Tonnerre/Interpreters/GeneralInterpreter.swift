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
struct GeneralInterpreter: Interpreter {
  let loader = GeneralLoader()
  func wrap(_ rawData: [TonnerreService], withTokens tokens: [String]) -> [ServicePack] {
    return rawData.map { provider in
      let keyword = type(of: provider).keyword
      if provider is DeferedServiceProtocol && keyword != tokens.first { return [] }
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
