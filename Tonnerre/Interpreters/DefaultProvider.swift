//
//  DefaultProvider.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-12-09.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum DefaultProvider {
  static var id: String? {
    set {
      let userDefault = UserDefaults.shared
      userDefault.set(newValue, forKey: "Tonnerre.Provider.Default")
    } get {
      let userDefault = UserDefaults.shared
      return userDefault.string(forKey: "Tonnerre.Provider.Default")
    }
  }
}
