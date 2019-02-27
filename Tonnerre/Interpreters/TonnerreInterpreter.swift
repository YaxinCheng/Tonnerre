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
    weak var previousList: TaggedList<ServicePack>? = nil
  }
  
  private let cache = Cache()
  static var serviceIDTrie = ServiceIDTrie(array: BuiltInProviderMap.IDtoKeyword.map { ($1, $0) })
  private let session = TonnerreSession.shared
  
  func interpret(input: String) -> TaggedList<ServicePack> {
    let tokens = tokenize(input: input)
    guard !(tokens.first?.isEmpty ?? false) else { return [] }
    
    session.cancelAll()
    let providers = fetchProviders(tokens: tokens)
    cache.previousRequest = input
    
    let taggedList = TaggedList<ServicePack>(array:
      providers.map { .provider($0) }, filter: { !$0.provider.keyword.isEmpty }
    )
    taggedList.lock = DispatchSemaphore(value: 1)
    defer { cache.previousList = taggedList }
    
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
    cache.previousList = nil
  }
  
  private func fetchProviders(tokens: [String]) -> [ServiceProvider] {
    let providers: [ServiceProvider]
    if cache.previousRequest == tokens.first! {
      providers = cache.previousProvider
        .filter { tokens.count >= $0.argLowerBound }
        .filter { tokens.count - ($0.keyword.isEmpty ? 0 : 1) <= $0.argUpperBound }
    } else {
      providers = TonnerreInterpreter.serviceIDTrie
        .find(basedOn: tokens.first!.lowercased())
        .compactMap { ProviderMap.shared.retrieve(byID: $0) }
        .filter { !DisableManager.shared.isDisabled(provider: $0) }
        .filter { !$0.defered || $0.keyword == tokens.first! }
        .filter { tokens.count >= $0.argLowerBound }
        .filter { tokens.count - ($0.keyword.isEmpty ? 0 : 1) <= $0.argUpperBound }
        .sorted {
          DisplayOrder.sortingScore(baseString: $0.keyword, query: tokens.first!, timeIdentifier: $0.id)
            >
          DisplayOrder.sortingScore(baseString: $1.keyword, query: tokens.first!, timeIdentifier: $1.id)
      }
      cache.previousProvider = providers
    }
    return providers
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
    let preparedServices: [ServicePack] = provider.prepare(withInput: requirements).map {
        if let provider = $0 as? ServiceProvider { return .provider(provider) }
        else { return .service(provider: provider, content: $0) }
      }
    destination.replace(at: .provider(provider),
                        elements: preparedServices)
    let previousServices = fetchPreviousServices(at: .provider(provider))
    if previousServices.count > preparedServices.count {
      destination.append(at: .provider(provider), elements: previousServices)
    }
    let asyncTask = DispatchWorkItem { [requirements, provider, preparedServices] in
      provider.supply(withInput: requirements) {
        let services: [ServicePack] = $0.map {
          if let provider = $0 as? ServiceProvider { return .provider(provider) }
          else { return .service(provider: provider, content: $0) }
        }
        if !(provider is BuiltInProvider) {
          if services.count > 0 {
            destination.replace(at: .provider(provider), elements: services)
          }
        } else {
          destination.replace(at: .provider(provider), elements: preparedServices)
          destination.append(at: .provider(provider), elements: services)
        }
      }
    }
    session.enqueue(task: asyncTask, waitTime: provider is WebService ? 0.1 : 0)
  }
  
  private func fetchPreviousServices(at tag: ServicePack) -> ArraySlice<ServicePack> {
    guard let previousList = cache.previousList else { return [] }
    return previousList[tag].dropFirst()
  }
}
