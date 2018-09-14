//
//  PrioriInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class PrioriInterpreter: InterpreterProtocol {
  typealias LoaderType = PrioriLoader
  typealias TargetType = ServicePack
  
  var cachedKey: String = ""
  var cachedProviders: Array<TonnerreService> = []
  let loader = PrioriLoader()
  
  func wrap(_ rawData: [TonnerreService], withTokens tokens: [String]) -> [ServicePack] {
    return rawData.map { provider in
      provider.prepare(input: Array(tokens[1...])).map { ServicePack(provider: provider, service: $0) }
    }.reduce([], +)
  }
}
