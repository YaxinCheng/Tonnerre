//
//  JSON.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

///
/// A easily traversable JSON object. Immutable & fast
///
struct JSON {
  /// The JSON Style
  ///
  /// **Valid options**:
  ///   - dict: dictionary/map like JSON. e.g. {"key": "value"}
  ///   - array: array like JSON. e.g. [1, 2, 3]
  ///   - atom: Not really a JSON, but just for the processing.
  ///           This appears only during the traverse
  private enum Style {
    /// Dictionary/map like JSON.
    ///
    /// For example
    /// ```
    /// {"key": "value"}
    /// ```
    case dict
    /// array like JSON
    ///
    /// For example
    /// ```
    /// [1, 2, 3]
    /// ```
    case array
    /// Not really a JSON, but just easy for the processing.
    /// This appears only during the traverse, as a **trasient** type
    case atom
  }
  /// Style attribute used for the traverse
  private let style: Style
  /// The rawValue this JSON represents.
  ///
  /// It can only be:
  ///   - Dictionary<String, Any>
  ///   - Array<Any>
  ///   - Any
  let rawValue: Any
  /// The number of elements inside this JSON
  let count: Int
  
  // MARK: - Constructors
  
  /// Construct a JSON object from the given data.
  /// - parameter data: the data read from a file or downloaded from internet that contains the json information
  ///
  /// - Warning: this constructor can fail if the data is not a JSON
  init?(data: Data) {
    do {
      rawValue = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
      if let dict = rawValue as? Dictionary<String, Any> {
        style = .dict
        count = dict.count
      } else if let array = rawValue as? Array<Any> {
        style = .array
        count = array.count
      } else {
        return nil
      }
    } catch {
      return nil
    }
  }
  
  /// Construct a JSON object from a dictionary.
  /// - parameter dictionary: the dictionary represented JSON
  init(dictionary: Dictionary<String, Any>) {
    style = .dict
    rawValue = dictionary
    count = dictionary.count
  }
  
  /// Construct a JSON object from an array.
  /// - parameter array: the array represented JSON
  init(array: Array<Any>) {
    style = .array
    rawValue = array
    count = array.count
  }
  
  /// Wrap up a random value to a JSON Object
  ///
  /// - parameter atomValue: the value that needs to be wrapped up
  ///
  /// - Note: this is not recommended for any use outside of traverse
  private init(atomValue: Any) {
    rawValue = atomValue
    style = .atom
    count = 1
  }
  
  /// A convenience constructor that auto-categorize value to its specific constructor
  /// - parameter autoPairedValue: the value that needs to be wrapped up
  /// - Note: this is only used during the traverse process
  private init(_ autoPairedValue: Any) {
    if let dict = autoPairedValue as? Dictionary<String, Any> {
      self.init(dictionary: dict)
    } else if let array = autoPairedValue as? Array<Any> {
      self.init(array: array)
    } else {
      self.init(atomValue: autoPairedValue)
    }
  }
  
  /// The key used to retrieve values from JSON objects.
  enum Key: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, Comparable {
    static func < (lhs: Key, rhs: Key) -> Bool {
      switch (lhs, rhs) {
      case (.number(let rawLeft), .number(let rawRight)):
        return rawLeft < rawRight
      case (.string(let rawLeft), .string(let rawRight)):
        return rawLeft < rawRight
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
    
    /// A string key for dictionary JSON.
    /// Can only be used for dictionary like JSON objects
    /// - Note: trying to retrieve values by String Key from
    ///     an array-like JSON would return nil
    case string(_ rawValue: String)
    /// A number key for array JSON.
    /// Can only be used for array like JSON objects
    /// - Note: trying to retrieve values by String Key from
    ///     an dictionary-like JSON would return nil
    case number(_ rawValue: Int)
    
    fileprivate var rawValue: Any {
      switch self {
      case .string(let rawValue): return rawValue
      case .number(let rawValue): return rawValue
      }
    }
  }
  
  /// Storage for JSON existing keys, with lazy loading
  private class KeyChain {
    /// The actual key storage
    private var keys: [Key]? = nil
    /// This function extract the keys from the JSON object
    /// - parameter json: where the keys come from
    /// - returns: an array of keys from the json object
    func getKeys(from json: JSON) -> [Key] {
      if keys != nil { return keys! }
      switch json.style {
      case .dict:
        keys = (json.rawValue as! [String: Any]).keys.map { .string($0) }
      case .array:
        keys = (0..<(json.rawValue as! [Any]).count).map { .number($0) }
      default:
        keys = []
      }
      return keys!
    }
  }
  /// The keychain to store keys
  private let keychain = KeyChain()
  /// An open ordered access to the JSON keys
  var keys: [Key] {
    return keychain.getKeys(from: self)
  }
  
  /// Serialize the JSON Object back to data
  func serialized() throws -> Data {
    return try JSONSerialization.data(withJSONObject: rawValue, options: .prettyPrinted)
  }
}

// MARK: - Subscripts & traverse
extension JSON {
  /// This function goes through the JSON object and get values
  /// level by level with the given keys
  /// - parameter json: a json where we needs to extract information from
  /// - parameter keys: a list of ordered keys to use for each level
  ///
  /// Example:
  ///
  /// With given JSON as below:
  /// ```
  /// {
  ///   "level1":
  ///   {
  ///     "level2": [1, 2, 3, 4]
  ///   },
  ///   ...
  /// }
  /// ```
  /// We give keys as below:
  /// ```
  /// ["level1", "level2", 0]
  /// ```
  /// It should return:
  /// ```
  /// 1
  /// ```
  private static func traverse(json: JSON, keys: [Key]) -> Any? {
    guard let firstKey = keys.first else { return json.rawValue }
    guard let nextJSON = json[firstKey] else { return nil }
    return traverse(json: JSON(nextJSON), keys: Array(keys.dropFirst()))
  }
  
  subscript(key: Key) -> Any? {
    switch (style, key) {
    case (.dict, .string(let stringKey)):
      return (rawValue as! [String: Any])[stringKey]
    case (.array, .number(let numberKey)):
      return (rawValue as! [Any])[numberKey]
    default: return nil
    }
  }
  
  subscript<T>(key: Key, default defaultMethod: @autoclosure ()->T) -> T {
    return (self[key] as? T) ?? defaultMethod()
  }
  
  subscript<T>(key: Int, default defaultMethod: @autoclosure ()->T) -> T {
    return self[.number(key), default: defaultMethod]
  }
  
  subscript<T>(key: String, default defaultMethod: @autoclosure ()->T) -> T {
    return self[.string(key), default: defaultMethod]
  }
  
  subscript(key: Int) -> Any? {
    return self[.number(key)]
  }
  
  subscript<T>(key: Int) -> T? {
    return self[key] as? T
  }
  
  subscript(key: String) -> Any? {
    return self[.string(key)]
  }
  
  subscript<T>(key: String) -> T? {
    return self[key] as? T
  }
  
  subscript(keys: [Key]) -> Any? {
    return JSON.traverse(json: self, keys: keys)
  }
  
  subscript(keys: Key...) -> Any? {
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
    return .init(count)
  }
  
  func index(after i: Index) -> Index {
    return .init(i.rawValue + 1)
  }
  
  subscript(position: Index) -> (key: Key, value: Any) {
    let key = keys[position.rawValue]
    let value = self[key]!
    return (key, value)
  }
}

extension JSON: ExpressibleByDictionaryLiteral {
  init(dictionaryLiteral elements: (JSON.Key, Any)...) {
    let dict = Dictionary(elements.map { ($0.0.rawValue as! String, $0.1) }) { first, second in return first }
    self.init(dictionary: dict)
  }
}

extension JSON: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: Any...) {
    self.init(array: elements)
  }
}
