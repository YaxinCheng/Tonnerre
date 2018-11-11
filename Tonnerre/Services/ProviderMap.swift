//
//  ProviderMap.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class ProviderMap {
  static let shared = ProviderMap()
  private init() {}
  private var registeredProviders: [String: ServiceProvider] = [:]
  
  func register(provider: ServiceProvider) {
    registeredProviders[provider.id] = provider
  }
  
  func retrieve(byID id: String) -> ServiceProvider? {
    return registeredProviders[id] ?? BuiltInProviderMap.retrieveType(baseOnID: id)?.init()
  }
}
