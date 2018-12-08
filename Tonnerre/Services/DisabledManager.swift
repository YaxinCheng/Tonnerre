//
//  DisabledManager.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class DisableManager {
  static let shared = DisableManager()
  
  private let disabledIDsKey = "Tonnerre.Providers.Disabled.IDs"
  private(set) var disabledIDs: Set<String> {
    get {
      let userDefault = UserDefaults.shared
      let ids = (userDefault.array(forKey: disabledIDsKey) as? [String]) ?? []
      return Set(ids)
    } set {
      let userDefault = UserDefaults.shared
      userDefault.set(Array(newValue), forKey: disabledIDsKey)
    }
  }
  
  private init() { }
  
  func isDisabled(providerID: String) -> Bool {
    return disabledIDs.contains(providerID)
  }
  
  func disable(providerID: String) {
    guard !disabledIDs.contains(providerID) else { return }
    disabledIDs.insert(providerID)
  }
  
  func enable(providerID: String) {
    guard disabledIDs.contains(providerID) else { return }
    disabledIDs.remove(providerID)
  }
}
