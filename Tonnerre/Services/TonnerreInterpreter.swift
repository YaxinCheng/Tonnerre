//
//  TonnerreInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreInterpreter {
  private static var loader = TonnerreServiceLoader()
  private var cachedServices = [TonnerreService]()
  private var lastQuery: String = ""
  
  private func tokenize(rawCmd: String) -> [String] {
    return rawCmd.components(separatedBy: .whitespaces)
  }
  
  private mutating func parse(tokens: [String]) -> [TonnerreService] {
    if tokens.first == lastQuery { return cachedServices }
    lastQuery = tokens.first!
    if tokens.count == 1 {
      cachedServices = TonnerreInterpreter.loader.autoComplete(key: tokens.first!)
      return cachedServices
    } else {
      cachedServices = TonnerreInterpreter.loader.exactMatch(key: tokens.first!)
      return cachedServices.isEmpty ? [LaunchService()] : cachedServices
    }
  }
  
  private func prepareService(service: TonnerreService, input: [String]) -> [ServiceResult] {
    let keywordCount = (service.keyword != "").hashValue
    let filteredTokens = input.filter { !$0.isEmpty }
    if filteredTokens.count == keywordCount + service.minTriggerNum
      || keywordCount == 0 || (filteredTokens.count > keywordCount && service.acceptsInfiniteArguments) {
      return service.prepare(input: Array(filteredTokens[keywordCount...])).map { queryResult in
        ServiceResult(service: service, value: queryResult)
      }
    } else if service.minTriggerNum != 0 {
      return [ServiceResult(service: service)]
    } else { return [] }
  }
  
  mutating func interpret(rawCmd: String) -> [ServiceResult] {
    guard !rawCmd.isEmpty else { return [] }
    let tokens = tokenize(rawCmd: rawCmd).filter { !$0.isEmpty }
    let services = parse(tokens: tokens)
    let possibleServices: [ServiceResult] = services.map { service in
      prepareService(service: service, input: tokens)
    }.reduce([], +)
    if possibleServices.isEmpty {
      let systemServices = TonnerreInterpreter.loader.loadSystemService(baseOn: tokens.first!)
      if systemServices.isEmpty {// Load default web search services
        let services: [WebService] = [GoogleSearch(suggestion: false), AmazonSearch(suggestion: false), WikipediaSearch(suggestion: false)]
        let values = services.map { $0.prepare(input: tokens) }
        return zip(services, values).map { ServiceResult(service: $0.0, value: $0.1.first!) }
      } else {// load system services
        return systemServices.map { prepareService(service: $0, input: tokens) }.reduce([], +)
      }
    } else {
      return possibleServices
    }
  }
}
