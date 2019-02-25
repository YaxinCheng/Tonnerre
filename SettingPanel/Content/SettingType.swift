//
//  SettingType.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2019-02-04.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

enum SettingType {
  case int(_ value: Int)
  case string(_ value: String)
  case bool(_ value: Bool)
  case array(_ value: [Any])
  
  var rawValue: Any {
    switch self {
    case .int(let value): return value
    case .bool(let value): return value
    case .string(let value): return value
    case .array(let value): return value
    }
  }
  
  init?(value: Any) {
    switch value {
    case let stringVal as String: self = .string(stringVal)
    case let intVal as Int: self = .int(intVal)
    case let boolVal as Bool: self = .bool(boolVal)
    case let arrayVal as [Any]: self = .array(arrayVal)
    default: return nil
    }
  }
}

extension SettingType: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self = .string(value)
  }
}

extension SettingType: ExpressibleByIntegerLiteral {
  init(integerLiteral value: Int) {
    self = .int(value)
  }
}

extension SettingType: ExpressibleByBooleanLiteral {
  init(booleanLiteral value: Bool) {
    self = .bool(value)
  }
}

extension SettingType: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: Any...) {
    self = .array(elements)
  }
}
