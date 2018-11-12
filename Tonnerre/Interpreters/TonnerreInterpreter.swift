//
//  TonnerreInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class TonnerreInterpreter {
  private class Cache {
    var previousRequest: String?
    var previousProvider: [ServiceProvider] = []
  }
  private let cache = Cache()
  static var serviceIDTrie = ServiceIDTrie(array: BuiltInProviderMap.IDtoKeyword.map { ($1, $0) })
  private let session = TonnerreSession.shared
  
  init() {
    ProviderMap.shared.start()
  }
  
  func interpret(input: String) -> ManagedList<ServicePack> {
    let tokens = tokenize(input: input)
    guard tokens.count > 0 else { return [] }
    
    let providers: [ServiceProvider]
    if cache.previousRequest == tokens.first! {
      providers = cache.previousProvider
    } else {
      providers = TonnerreInterpreter.serviceIDTrie
        .find(basedOn: tokens.first!)
        .compactMap { ProviderMap.shared.retrieve(byID: $0) }
        .filter { !DisableManager.shared.isDisabled(provider: $0) }
        .filter { !$0.defered || $0.keyword == tokens.first! }
        .filter { tokens.count <= $0.argUpperBound }
      cache.previousProvider = providers
      #warning("Provide a default service loader")
    }
    cache.previousRequest = input
    
    let managedList = ManagedList<ServicePack>(array: providers
      .filter { !$0.keyword.isEmpty }
      .map { .provider($0) }
    )
    managedList.lock = DispatchSemaphore(value: 1)
    
    #warning("Separate to several work item, and queue them up")
    let asyncTask = DispatchWorkItem {
      for provider in providers {
        let keywordCount = provider.keyword.isEmpty ? 0 : 1
        guard
          tokens.count - keywordCount >= provider.argLowerBound,
          tokens.count - keywordCount <= provider.argUpperBound
        else { continue }
        let services: [ServicePack] = provider.prepare(withInput: Array(tokens[keywordCount...]))
              .map {
                if let provider = $0 as? ServiceProvider { return .provider(provider) }
                else { return .service(provider: provider, content: $0) }
              }
        managedList.replace(at: .provider(provider), elements: services)
      }
    }
    session.send(request: asyncTask)
    
    return managedList
  }
  
  func clearCache() {
    cache.previousProvider = []
    cache.previousRequest = nil
  }
  
  /**
   Tokenize user input
   - parameter input: user input
   - returns: tokenized tokens
   */
  private func tokenize(input: String) -> [String] {
    return input.trimmed.components(separatedBy: .whitespacesAndNewlines)
  }
}
