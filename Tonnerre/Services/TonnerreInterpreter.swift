//
//  TonnerreInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreInterpreter {
  /**
   ServiceLoader loads possible services based on user inputs
  */
  static let loader = TonnerreServiceLoader()
  /**
   Cached services for last input keyword
  */
  private var cachedServices = [TonnerreService]()
  /**
   Cached last input query keyword
  */
  private var lastQuery: String = ""
  
  /**
   Tokenize the input query into tokens by white spaces
   - parameter rawCmd: the original input typed in the TonnerreField
   - returns: an array of tokens (keyword + inputQueries)
  */
  private func tokenize(rawCmd: String) -> [String] {
    return rawCmd.components(separatedBy: .whitespaces)
  }
  
  /**
   Load possible services based on the input keyword
   - parameter keyword: the first non space word user typed in the TonnerreField
   - returns: possible services found based on this keyword
  */
  private mutating func parse(keyword: String) -> [TonnerreService] {
    // If the keyword remains unchanged from last time, just return the cached services
    if keyword == lastQuery { return cachedServices }
    lastQuery = keyword// Update the cached key
    cachedServices = type(of: self).loader.load(keyword: keyword)// Cache
    return cachedServices
  }
  
  /**
   Prepare the services with the user queries.
   - parameter service: the service which needs to be prepared
   - parameter input: the keyword (first word) + an array of words user put after the keyword
   - returns:
     - An array of service packs provided by the service provider based on the user queries, if the number of queries matches with the service requirement
     - Or the service itself, it the number of queries does not match the requirement
  */
  private func prepareService(service: TonnerreService, input: [String]) -> [ServicePack] {
    let keyword = type(of: service).keyword
    let keywordCount = (!keyword.isEmpty).hashValue// Check if the service has keyword
    if service is DeferedServiceProtocol && (input.first?.count ?? 0) < keyword.count { return [] }
    // queries must be greater than the service's lower bound and less than the upper bound
    if input.count >= keywordCount + service.argLowerBound && input.count - keywordCount <= service.argUpperBound {
      return service.prepare(input: Array(input[keywordCount...])).map { queryResult in// strip out the keyword
        ServicePack(provider: service, service: queryResult)// Bind the each query result with the service
      }
    } else if keywordCount != 0 && service.argUpperBound > 0 {
      // If a service has no keyword or its upper bound is less or equal than 0, then it cannot be displayed
      return [ServicePack(provider: service)]
    } else { return [] }
  }
  
  /**
   Clear the current cached services and keyword
  */
  mutating func clearCache() {
    lastQuery = ""
    cachedServices = []
  }
  
  /**
   React to user input, and generate services and related service providers
   - parameter rawCmd: the string user typed in the TonnerreField
   - returns: an array of service packs
  */
  mutating func interpret(rawCmd: String) -> [ServicePack] {
    let trimmedCmd = rawCmd// Strip the beginning white spaces, and reduce multiple continuous spaces to one
        .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
        .replacingOccurrences(of: "\\s\\s+", with: " ", options: .regularExpression)
    guard !trimmedCmd.isEmpty else { return [] }
    let tokens = tokenize(rawCmd: trimmedCmd)
    let services = parse(keyword: tokens.first!)
    let possibleServices: [ServicePack] = services.map { service in
      prepareService(service: service, input: tokens)
    }.reduce([], +)
    if possibleServices.isEmpty {
      // If no service is available, then try system services, and if no, use default service
      let systemServices = type(of: self).loader.load(keyword: tokens.first!, type: .system)
      if systemServices.isEmpty {// Load default web search services
        clearCache()
        let service = GoogleSearch()
        let value = service.prepare(input: tokens)
        return value.map { ServicePack(provider: service, service: $0) }
      } else {// load system services
        cachedServices = systemServices
        return systemServices.map { prepareService(service: $0, input: tokens) }.reduce([], +)
      }
    } else {
      return possibleServices
    }
  }
}
