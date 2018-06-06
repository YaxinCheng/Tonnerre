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
  
  private func tokenize(rawCmd: String) -> [String] {
    return rawCmd.components(separatedBy: .whitespaces)
  }
  
  private func parse(tokens: [String]) -> [TonnerreService] {
    if tokens.count == 1 {
      return TonnerreInterpreter.loader.autoComplete(key: tokens.first!)
    } else {
      let matchedServices = TonnerreInterpreter.loader.exactMatch(key: tokens.first!)
      return matchedServices.isEmpty ? [LaunchService()] : matchedServices
    }
  }
  
  private func prepareService(service: TonnerreService, input: [String]) -> [ServiceResult] {
    let keywordCount = (service.keyword != "").hashValue
    let filteredTokens = input.filter({ !$0.isEmpty })
    if filteredTokens.count == keywordCount + service.arguments.count || keywordCount == 0 {
      return service.prepare(input: Array(filteredTokens[keywordCount...])).map { queryResult in
        ServiceResult(service: service, value: queryResult)
      }
    } else if service.arguments.count != 0 {
      return [ServiceResult(service: service)]
    } else { return [] }
  }
  
  func interpret(rawCmd: String) -> [ServiceResult] {
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
