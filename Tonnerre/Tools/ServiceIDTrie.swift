//
//  ServiceIDTrie.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 A trie keeps service ids with their related keywords
 */
struct ServiceIDTrie {
  private final class Node {
    /// This dictionary stores the values starts with the same common prefix
    /// with the current value + the next letter
    var children: [Character: Node]
    /// Ordered queue of strings with the same common prefix
    var values: Array<String>
    
    /**
     Construct a node with current values and its children
     - parameter children: the children of the current node
     - parameter values: a sequence of values that needs to be stored
    */
    init<T: Sequence>(children: [Character: Node], values: T)
      where T.Element == String {
      self.children = children
      self.values = Array(values)
    }
    
    /**
     Empty constructor
    */
    init() {
      children = [:]
      values = []
    }
  }
  /// Root node of this trie
  private let rootNode: Node
  /// A list of values with empty keyword
  private var wildcards: [String] = []
  private var removedValues: Set<String> = []
  
  /**
   Insert a value into the trie
   - parameter key: the key associated with the value
   - parameter value: the element needs to be inserted
   */
  mutating func insert(value: String, key: @autoclosure ()->String) {
    let keyword = key()
    if keyword.isEmpty {
      wildcards.append(value)
      return
    } else if removedValues.remove(value) != nil { return }
    var node = rootNode
    var index = keyword.startIndex
    node.values.append(value) // Always add every value to the root
    while index < keyword.endIndex { // Going through the characters
      let char = keyword[index]
      guard let next = node.children[char] else { break } // Make sure there is existing entry, otherwise break
      node = next
      node.values.append(value)
      index = keyword.index(after: index)
    }
    if index < keyword.endIndex && index >= keyword.startIndex {// Add new entries into the trie
      for char in keyword[index...] {
        node.children[char] = Node(children: [:], values: [value])
        node = node.children[char]!
      }
    }
  }
  
  /**
   Find a list of stored values with given string
   - parameter value: the key with which the elments associate
   - returns: an array of elements that share the same beginning as the `value`
   */
  func find(basedOn key: String) -> [String] {
    if key.isEmpty { return Array(wildcards) }
    var node = rootNode
    for char in key {
      guard let next = node.children[char] else { return Array(wildcards) }
      node = next
    }
    return (node.values + wildcards).filter { !removedValues.contains($0) }
  }
  
  /**
   Remove a value from the trie
   - parameter value: the value that needs to be removed
  */
  mutating func remove(value: String) {
    removedValues.insert(value)
  }
}

extension ServiceIDTrie: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: (key: String, value: String)...) {
    rootNode = Node()
    for (key, value) in elements {
      insert(value: value, key: key)
    }
  }
  
  ///Creates an instance initialized with the given elements
  /// - parameter array: an array of key value pairs
  init(array: [(key: String, value: String)]) {
    rootNode = Node()
    for (key, value) in array {
      insert(value: value, key: key)
    }
  }
}
