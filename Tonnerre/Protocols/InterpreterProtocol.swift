//
//  InterpreterProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol InterpreterProtocol: class {
  associatedtype LoaderType: LoaderProtocol
  associatedtype TargetType
  var cachedKey: String { get set }
  var cachedProviders: Array<LoaderType.DataType> { get set }
  var loader: LoaderType { get }
  func wrap(_ rawData: [LoaderType.DataType], withTokens tokens: [String]) -> [TargetType]
}

extension InterpreterProtocol {
  func tokenize(input: String) -> [String] {
    let trimmed = input
      .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
      .replacingOccurrences(of: "\\s\\s+", with: " ", options: .regularExpression)
    return trimmed.components(separatedBy: .whitespacesAndNewlines)
  }
  
  func interpret(input: String) -> [TargetType] {
    let tokens = tokenize(input: input)
    guard let keyword = tokens.first else { return [] }
    if keyword != cachedKey {
      cachedKey = keyword
      cachedProviders = loader.find(keyword: keyword)
    }
    return wrap(cachedProviders, withTokens: tokens)
  }
  
  func clearCache() {
    cachedKey = ""
    cachedProviders = []
  }
}
