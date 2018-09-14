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
struct DelayedServiceLoader: LoaderProtocol {
  typealias DataType = TonnerreService
  private var providerTrie: Trie<TonnerreService.Type>
  
  init() {
    let DelayedServices: [TonnerreService.Type] = [ApplicationService.self, VolumeService.self]
    
    let saveToSettings: ([TonnerreService.Type]) -> () = { providers in
      DispatchQueue.global(qos: .background).async {
        let userDefault = UserDefaults.shared
        let settings = providers.map { $0.init() }
          .map { [$0.name, $0.content, type(of: $0).settingKey] }
        userDefault.set(settings, forKey: .delayedProviders)
      }
    }
    saveToSettings(DelayedServices)
    
    providerTrie = Trie(values: DelayedServices) { $0.keyword }
  }
  
  func find(keyword: String) -> [TonnerreService] {
    return providerTrie.find(value: keyword)
      .filter { !$0.isDisabled }
      .map { $0.init() }
  }
}
