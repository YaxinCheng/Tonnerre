//
//  TonnerreInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-15.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 The main interpreter access to interpret user input.
 
 It encapsulates different interpreters and the logics of using them
 */
struct TonnerreInterpreter {
  private let generalInterpreter = GeneralInterpreter(loader: GeneralLoader())
  private let delayedInterpreter = GeneralInterpreter(loader: DelayedServiceLoader())
  private let prioritInterpreter = InstantInterpreter(loader: PrioriLoader())
  private let defaultInterpreter = InstantInterpreter(loader: DefaultLoader())
  private let tneInterpreter     = TNEInterpreter()
  private let webExtInterpreter  = WebExtInterpreter()
  
  private func isEmpty(_ pack: PrioritizedPack) -> Bool {
    return pack.0.isEmpty && pack.1.isEmpty && pack.2.isEmpty
  }
  
  private func sum(_ pack: PrioritizedPack) -> [ServicePack] {
    return pack.2 + pack.1 + pack.0
  }
  /**
   Interpret user input into ServicePacks
   - parameter input: user input
   - returns: well structured ServicePacks
  */
  func interpret(input: String) -> [ServicePack] {
    guard !input.isEmpty else { return [] }
    var providedServices = tneInterpreter.interpret(input: input)
    providedServices += webExtInterpreter.interpret(input: input)
    providedServices += generalInterpreter.interpret(input: input)
    providedServices += prioritInterpreter.interpret(input: input)
    if isEmpty(providedServices) {
      providedServices += delayedInterpreter.interpret(input: input)
    }
    if isEmpty(providedServices) {
      providedServices += defaultInterpreter.interpret(input: input)
    }
    return sum(providedServices)
  }
  
  func clearCache() {
    prioritInterpreter.clearCache()
  }
}

fileprivate typealias PrioritizedPack = ([ServicePack], [ServicePack], [ServicePack])
fileprivate func += (lhs: inout PrioritizedPack, rhs: PrioritizedPack) {
  lhs.0 += rhs.0
  lhs.1 += rhs.1
  lhs.2 += rhs.2
}
