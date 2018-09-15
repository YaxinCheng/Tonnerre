//
//  PrioriInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct PrioriInterpreter: Interpreter {
  typealias LoaderType = PrioriLoader
  let loader = PrioriLoader()
  
  func wrap(_ rawData: [TonnerreService], withTokens tokens: [String]) -> [ServicePack] {
    return rawData.map { provider in
      provider.prepare(input: tokens).map { ServicePack(provider: provider, service: $0) }
    }.reduce([], +)
  }
}
