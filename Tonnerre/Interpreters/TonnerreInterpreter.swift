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
    ClipboardService.monitor.start()
  }
  
  func interpret(input: String) -> TaggedList<ServicePack> {
    let tokens = tokenize(input: input)
    guard tokens.count > 0 else { return [] }
    
    session.cancel()
    let providers: [ServiceProvider]
    if cache.previousRequest == tokens.first! {
      providers = cache.previousProvider
    } else {
      providers = TonnerreInterpreter.serviceIDTrie
        .find(basedOn: tokens.first!.lowercased())
        .compactMap { ProviderMap.shared.retrieve(byID: $0) }
        .filter { !DisableManager.shared.isDisabled(provider: $0) }
        .filter { !$0.defered || $0.keyword == tokens.first! }
        .filter { tokens.count - ($0.keyword.isEmpty ? 0 : 1) <= $0.argUpperBound }
        .sorted {
          DisplayOrder.sortingScore(baseString: $0.keyword, query: tokens.first!, timeIdentifier: $0.id)
            >
          DisplayOrder.sortingScore(baseString: $1.keyword, query: tokens.first!, timeIdentifier: $1.id)
        }
      cache.previousProvider = providers
    }
    cache.previousRequest = input
    
    let taggedList = TaggedList<ServicePack>(array:
      providers.map { .provider($0) }, filter: { !$0.provider.keyword.isEmpty }
    )
    taggedList.lock = DispatchSemaphore(value: 1)
    
    for provider in providers {
      let keywordCount = provider.keyword.isEmpty ? 0 : 1
      guard
        tokens.count - keywordCount >= provider.argLowerBound,
        tokens.count - keywordCount <= provider.argUpperBound
      else { continue }
      let passinContent = Array(tokens[keywordCount...])
      supply(fromProvider: provider, requirements: passinContent, destination: taggedList)
    }
    if taggedList.count == 0 && !input.isEmpty {
      // If no service is available, use default
      let defaultProvider = ProviderMap.shared.defaultProvider ?? GoogleSearch()
      guard tokens.count <= defaultProvider.argUpperBound else { return taggedList }
      supply(fromProvider: defaultProvider, requirements: tokens, destination: taggedList)
    }
    
    return taggedList
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
    return input.truncatedSpaces.components(separatedBy: .whitespacesAndNewlines)
  }
  
  private func supply(fromProvider provider: ServiceProvider, requirements: [String], destination: TaggedList<ServicePack>) {
    destination.replace(at: .provider(provider),
                        elements: provider.prepare(withInput: requirements)
                          .map {
                            if let provider = $0 as? ServiceProvider { return .provider(provider) }
                            else { return .service(provider: provider, content: $0) }
                        })
    let asyncTask = DispatchWorkItem { [requirements, provider] in
      provider.supply(withInput: requirements) {
        let services: [ServicePack] = $0.map {
          if let provider = $0 as? ServiceProvider { return .provider(provider) }
          else { return .service(provider: provider, content: $0) }
        }
        guard services.count > 0 else { return }
        if !(provider is BuiltInProvider) {
          destination.replace(at: .provider(provider), elements: services)
        } else {
          destination.append(at: .provider(provider), elements: services)
        }
      }
    }
    session.enqueue(task: asyncTask)
  }
}
