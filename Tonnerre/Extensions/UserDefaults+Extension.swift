//
//  UserDefaults+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension UserDefaults {
  func value(forKey key: StoredKey) -> Any? {
    return value(forKey: key.rawValue)
  }
  
  func set(_ value: Any, forKey key: StoredKey) {
    if let url = value as? URL {
      set(url, forKey: key.rawValue)
    } else {
      set(value, forKey: key.rawValue)
    }
  }
  
  func bool(forKey key: StoredKey) -> Bool {
    return bool(forKey: key.rawValue)
  }
}
