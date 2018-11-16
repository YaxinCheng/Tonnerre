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
    var values: Heap<String>
    
    /**
     Construct a node with current values and its children
     - parameter children: the children of the current node
     - parameter values: a sequence of values that needs to be stored
    */
    init<T: Sequence>(children: [Character: Node], values: T)
      where T.Element == String {
      self.children = children
      self.values = Heap<String>(newElements: values) {
        ProviderMap.shared.getSortingScore(byID: $0)
        >
        ProviderMap.shared.getSortingScore(byID: $1)
      }
    }
    
    /**
     Empty constructor
    */
    init() {
      children = [:]
      values = Heap<String> {
        ProviderMap.shared.getSortingScore(byID: $0)
          >
        ProviderMap.shared.getSortingScore(byID: $1)
      }
    }
  }
  /// Root node of this trie
  private let rootNode: Node
  /// A list of values with empty keyword
  private var wildcards: [String] = []
  
  /**
   Insert a value into the trie
   - parameter key: the key associated with the value
   - parameter value: the element needs to be inserted
   */
  mutating func insert(key: String, value: String) {
    if key.isEmpty {
      wildcards.append(value)
      return
    }
    var node = rootNode
    var index = key.startIndex
    node.values.add(value) // Always add every value to the root
    while index < key.endIndex { // Going through the characters
      let char = key[index]
      guard let next = node.children[char] else { break } // Make sure there is existing entry, otherwise break
      node = next
      node.values.add(value)
      index = key.index(after: index)
    }
    if index < key.endIndex && index >= key.startIndex {// Add new entries into the trie
      for char in key[index...] {
        node.children[char] = Node(children: [:], values: [value])
        node = node.children[char]!
      }
    }
  }
  
  /**
   Update the order for a specific value with a specific key
   - parameter key: the key is used to locate the value in the trie
   - parameter value: the value is used to make reorder faster
  */
  mutating func updateHeap(key: String, value: String) {
    guard !key.isEmpty else { return }
    var node = rootNode
    for character in key {
      guard
        let next = node.children[character]
      else { return }
      let index = node.values.find(element: value)
      node.values.reorderUp(from: index)
      node = next
    }
  }
  
  /**
   Find a list of stored values with given string
   - parameter value: the key with which the elments associate
   - returns: an array of elements that share the same beginning as the `value`
   */
  func find(basedOn key: String) -> [String] {
    if key.isEmpty { return wildcards }
    var node = rootNode
    for char in key {
      guard let next = node.children[char] else { return wildcards }
      node = next
    }
    var valuesCopy = node.values
    valuesCopy.add(contentOf: wildcards)
    let linearized = valuesCopy.linearized()
    return linearized
  }
  
  /**
   Remove a value from the trie
   - parameter key: the key is used to locate the value in the trie
   - parameter value: the value that needs to be removed
  */
  mutating func remove(key: String, value: String) {
    if key.isEmpty {
      wildcards.removeAll { $0 == value }
      return
    }
    rootNode.values.remove(element: value)
    var node = rootNode
    for character in key {
      guard
        let next = node.children[character]
      else { return }
      next.values.remove(element: value)
      node = next
    }
  }
}

extension ServiceIDTrie: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: (key: String, value: String)...) {
    rootNode = Node()
    for (key, value) in elements {
      insert(key: key, value: value)
    }
  }
  
  ///Creates an instance initialized with the given elements
  /// - parameter array: an array of key value pairs
  init(array: [(key: String, value: String)]) {
    rootNode = Node()
    for (key, value) in array {
      insert(key: key, value: value)
    }
  }
}
