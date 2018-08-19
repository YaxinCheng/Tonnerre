//
//  UserDefaults+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension UserDefaults {
  func url(forKey key: StoredKey) -> URL? {
    return url(forKey: key.rawValue)
  }
  
  func object(forKey key: StoredKey) -> Any? {
    return object(forKey: key.rawValue)
  }
  
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
  
  func dictionary(forKey key: StoredKey) -> [String: Any]? {
    return dictionary(forKey: key.rawValue)
  }
  
  static var shared: UserDefaults {
    return UserDefaults(suiteName: "Tonnerre")!
  }
}
