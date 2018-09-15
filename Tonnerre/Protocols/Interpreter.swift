//
//  InterpreterProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 A protocol used to define interpreters
 
 Each interpreter should be able to return designated ServicePacks with given input
 
 The only two functions provided to use are
 - `interpret(String)->[ServicePack]`
 - `clearCache()`
 */
protocol Interpreter {
  /**
   The type of service loader the interpreter is using
   */
  associatedtype LoaderType: ServiceLoader
  /**
   The loader object that used to load services
  */
  var loader: LoaderType { get }
  /**
   This function wraps the loaded services (from laoder) to ServicePacks
   - parameter rawData: Raw services loaded from the laoder
   - parameter tokens: the user input after tokenization
   - returns: An array of well-structured ServicePacks
  */
  func wrap(_ rawData: [LoaderType.ServiceType], withTokens tokens: [String]) -> [ServicePack]
}

extension Interpreter {
  /**
   Tokenize user input
   - parameter input: user input
   - returns: tokenized tokens
  */
  private func tokenize(input: String) -> [String] {
    let trimmed = input.lowercased()
      .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
      .replacingOccurrences(of: "\\s\\s+", with: " ", options: .regularExpression)
    return trimmed.components(separatedBy: .whitespacesAndNewlines)
  }
  
  /**
   Interpret user input as a list of ServicePacks
   - parameter input: user input
   - returns: A list of ServicePacks
  */
  func interpret(input: String) -> [ServicePack] {
    let tokens = tokenize(input: input)
    guard let keyword = tokens.first else { return [] }
    return wrap(loader.load(keyword: keyword), withTokens: tokens)
  }
}
