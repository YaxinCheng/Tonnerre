//
//  DisableManager+Provider.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension DisableManager {
  func isDisabled(provider: ServiceProvider) -> Bool {
    return isDisabled(providerID: provider.id)
  }
  
  func disable(provider: ServiceProvider) {
    disable(providerID: provider.id)
  }
  
  func isDisabled(builtinProvider: BuiltInProvider.Type) -> Bool {
    let id = BuiltInProviderMap.extractKeyword(from: builtinProvider)
    return isDisabled(providerID: id)
  }
  
  func disable(builtinProvider: BuiltInProvider.Type) {
    let id = BuiltInProviderMap.extractKeyword(from: builtinProvider)
    disable(providerID: id)
  }
}
