//
//  PrioriLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class PrioriLoader: ServiceLoader {
  typealias ServiceType = BuiltInProvider
  private let providers: [BuiltInProvider]
  var cachedKey: String = ""
  var cachedProviders: Array<BuiltInProvider> = []
  
  func _find(keyword: String) -> [BuiltInProvider] {
    return providers
  }
  
  init() {
    providers  = [LaunchService(), CalculationService(), URLService(), CurrencyService()]
    let saveToSettings: (ArraySlice<BuiltInProvider>) -> () = { providers in
      DispatchQueue.global(qos: .background).async {
        let userDefault = UserDefaults.shared
        let settings = providers.map { [$0.keyword, $0.name, $0.content, $0.id] }
        userDefault.set(settings, forKey: .prioriProviders)
      }
    }
    saveToSettings(providers[1...])
  }
}
