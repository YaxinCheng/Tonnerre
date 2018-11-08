//
//  DelayedServiceLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 All service providers is loaded when general service providers cannot be loaded
*/
final class DelayedServiceLoader: ServiceLoader {
  typealias ServiceType = BuiltInProvider
  private var providerTrie: Trie<BuiltInProvider.Type>
  var cachedKey: String = ""
  var cachedProviders: Array<BuiltInProvider> = []
  
  init() {
    let DelayedServices: [BuiltInProvider.Type] = [ApplicationService.self, VolumeService.self]
    
    let saveToSettings: ([BuiltInProvider.Type]) -> () = { providers in
      DispatchQueue.global(qos: .background).async {
        let userDefault = UserDefaults.shared
        let settings = providers.map { $0.init() }
          .map { [$0.keyword, $0.name, $0.content, $0.id] }
        userDefault.set(settings, forKey: .delayedProviders)
      }
    }
    saveToSettings(DelayedServices)
    
    providerTrie = Trie(values: DelayedServices) { BuiltInProviderMap.extractKeyword(from: $0) }
  }
  
  func _find(keyword: String) -> [BuiltInProvider] {
    return providerTrie.find(value: keyword.lowercased())
      .filter { !DisableManager.shared.isDisabled(builtinProvider: $0) }
      .map { $0.init() }
  }
}
