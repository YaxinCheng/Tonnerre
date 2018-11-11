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
  
  func isDisabled(builtinProvider: BuiltInProvider.Type) -> Bool {
    let id = "Tonnerre.Provider.BuiltIn.\(builtinProvider.self)"
    return isDisabled(providerID: id)
  }
}
