//
//  JSON.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum JSON {
  
  case dict(_ rawValue: Dictionary<String, JSON>)
  case array(_ rawValue: Array<JSON>)
  case atom(_ rawValue: Any)
  
  // MARK: - Key
  /**
   Index for JSON objects.
  */
  enum Key: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, Comparable {
    static func < (lhs: JSON.Key, rhs: JSON.Key) -> Bool {
      switch (lhs, rhs) {
      case (.number(let rawLeft), .number(let rawRight)):
        return rawLeft < rawRight
      case (.string(let rawLeft), .string(let rawRight)):
        return rawLeft < rawRight
      case (.none, .none):
        return true
      default:
        fatalError("Invalid comparison")
      }
    }
    
    init(integerLiteral value: Int) {
      self = .number(value)
    }
    
    init(stringLiteral value: String) {
      self = .string(value)
    }
    
    case string(_ rawValue: String)
    case number(_ rawValue: Int)
    case none
  }

  // MARK: - JSON
  
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
  
  var rawValue: Any {
    switch self {
    case .dict(let dict):   return dict
    case .array(let array): return array
    case .atom(let value):  return value
    }
  }
  
  var keys: [Key] {
    switch self {
    case .dict(let dictionary):
      return dictionary.keys.map { .string($0) }
    case .array(let array):
      return (0..<array.count).map { .number($0) }
    case .atom(_):
      return [.none]
    }
  }
  
  subscript(key: Key) -> JSON? {
    switch (self, key) {
    case (.dict(let rawDict), .string(let stringKey)):
      return rawDict[stringKey]
    case (.array(let rawArray), .number(let numberKey)):
      return rawArray[numberKey]
    default: return nil
    }
  }

  subscript(key: String) -> JSON? {
    return self[.string(key)]
  }

  subscript(key: Int) -> JSON? {
    return self[.number(key)]
  }

  subscript(keys: [Key]) -> JSON? {
    var current: JSON?
    var unretrievedKeys = keys
    while unretrievedKeys.count > 0 && current != nil {
      current = self[unretrievedKeys.removeFirst()]
    }
    return current
  }

  subscript(keys: Key...) -> JSON? {
    return self[keys]
  }
}

extension JSON: Collection {
  
  // MARK: - Index
  struct Index: Comparable {
    static func < (lhs: Index, rhs: Index) -> Bool {
      return lhs.rawValue < rhs.rawValue
    }
    fileprivate let rawValue: Int
    fileprivate init(_ rawValue: Int) { self.rawValue = rawValue }
  }
  
  var startIndex: Index {
    return .init(0)
  }
  
  var endIndex: Index {
    return .init(keys.count)
  }
  
  func index(after i: Index) -> Index {
    return .init(i.rawValue + 1)
  }
  
  subscript(position: Index) -> (key: Key, value: JSON) {
    let key = keys[position.rawValue]
    let value = self[key]!
    return (key, value)
  }
}
