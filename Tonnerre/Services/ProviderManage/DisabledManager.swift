//
//  DisabledManager.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/// Service Providers are enabled and disabled through this class
/// . Use the shared instance to access the information
final class DisableManager {
  /// Shared instance of a disable manager
  static let shared = DisableManager()
  
  /// A set of ids of providers that are disabled
  private(set) var disabledIDs: Set<String> {
    get {
      switch TonnerreSettings.get(fromKey: .disabledServices) {
      case .array(let value)? where value is [String]: return Set(value as! [String])
      default: return []
      }
    } set {
      TonnerreSettings.set(.array(Array(newValue)), forKey: .disabledServices)
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
