//
//  TonnerreInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreInterpreter {
  static var loader = TonnerreServiceLoader()
  private var cachedServices = [TonnerreService]()
  private var lastQuery: String = ""
  
  private func tokenize(rawCmd: String) -> [String] {
    return rawCmd.components(separatedBy: .whitespaces)
  }
  
  private mutating func parse(tokens: [String]) -> [TonnerreService] {
    if tokens.first == lastQuery { return cachedServices }
    lastQuery = tokens.first!
    if tokens.first!.starts(with: "@") {
      cachedServices = TonnerreInterpreter.loader.autoComplete(key: tokens.first!, type: .interpreter)
    } else {
      cachedServices = TonnerreInterpreter.loader.autoComplete(key: tokens.first!)
    }
    return cachedServices
  }
  
  private func prepareService(service: TonnerreService, input: [String]) -> [ServiceResult] {
    let keywordCount = (type(of: service).keyword != "").hashValue
    if input.count >= keywordCount + service.argLowerBound && input.count - keywordCount <= service.argUpperBound {
      return service.prepare(input: Array(input[keywordCount...])).map { queryResult in
        ServiceResult(service: service, value: queryResult)
      }
    } else if keywordCount != 0 && service.argUpperBound != 0 {
      return [ServiceResult(service: service)]
    } else { return [] }
  }
  
  mutating func clearCache() {
    lastQuery = ""
    cachedServices = []
  }
  
  mutating func interpret(rawCmd: String) -> [ServiceResult] {
    guard !rawCmd.isEmpty else { return [] }
    let tokens = tokenize(rawCmd: rawCmd)
    let services = parse(tokens: tokens)
    let possibleServices: [ServiceResult] = services.map { service in
      prepareService(service: service, input: tokens)
    }.reduce([], +)
    if possibleServices.isEmpty {
      let systemServices = TonnerreInterpreter.loader.autoComplete(key: tokens.first!, type: .system)
      if systemServices.isEmpty {// Load default web search services
        let services: [WebService] = [GoogleSearch(suggestion: false), AmazonSearch(suggestion: false), WikipediaSearch(suggestion: false)]
        cachedServices = services
        lastQuery = ""
        let values = services.map { $0.prepare(input: tokens) }
        return zip(services, values).map { ServiceResult(service: $0.0, value: $0.1.first!) }
      } else {// load system services
        cachedServices = systemServices
        return systemServices.map { prepareService(service: $0, input: tokens) }.reduce([], +)
      }
    } else {
      return possibleServices
    }
  }
}
