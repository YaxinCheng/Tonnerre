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
  private let generalInterpreter = GeneralInterpreter()
  private let delayedInterpreter = DelayedInterpreter()
  private let prioritInterpreter = PrioriInterpreter()
  private let tneInterpreter     = TNEInterpreter()
  private let webExtInterpreter  = WebExtInterpreter()
  
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
    if providedServices.isEmpty {
      providedServices += delayedInterpreter.interpret(input: input)
    }
    return providedServices
  }
}
