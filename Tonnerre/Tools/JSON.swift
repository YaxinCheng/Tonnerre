//
//  JSON.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum JSON {
  enum Index: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
      self = .number(value)
    }
    
    init(stringLiteral value: String) {
      self = .string(value)
    }
    case string(_ rawValue: String)
    case number(_ rawValue: Int)
  }
  
  case dict(_ rawValue: Dictionary<String, JSON>)
  case array(_ rawValue: Array<JSON>)
  case atom(_ rawValue: Any)
  
  init?(data: Data) {
    do {
      let object = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
      self = JSON.wrap(object)
    } catch {
      return nil
    }
  }
  
  init(dictionary: Dictionary<String, Any>) {
    self = JSON.wrap(dictionary)
  }
  
  init(array: Array<Any>) {
    self = JSON.wrap(array)
  }
  
  private static func wrap(_ rawValue: Any) -> JSON {
    if let dict = rawValue as? Dictionary<String, Any> {
      return .dict(Dictionary(uniqueKeysWithValues:
        dict.map { ($0, wrap($1)) }
      ))
    } else if let array = rawValue as? Array<Any> {
      return .array(array.map(wrap))
    } else {
      return .atom(rawValue)
    }
  }
  
  private func retrieve(key: Index) -> JSON? {
    switch (key, self) {
    case (.string(let stringKey), .dict(let rawDict)):
      return rawDict[stringKey]
    case (.number(let numberKey), .array(let rawArray)):
      return rawArray[numberKey]
    default: return nil
    }
  }
  
  private var rawValue: Any {
    switch self {
    case .dict(let dict):   return dict
    case .array(let array): return array
    case .atom(let value):  return value
    }
  }
  
  subscript(key: String) -> Any? {
    return retrieve(key: .string(key))
  }
  
  subscript(key: Int) -> Any? {
    return retrieve(key: .number(key))
  }
  
  subscript(key: Index) -> Any? {
    return retrieve(key: key)?.rawValue
  }
  
  subscript(keys: Index...) -> Any? {
    var current: JSON?
    var unretrievedKeys = keys
    while unretrievedKeys.count > 0 && current != nil {
      current = retrieve(key: unretrievedKeys.removeFirst())
    }
    return current?.rawValue
  }
}
