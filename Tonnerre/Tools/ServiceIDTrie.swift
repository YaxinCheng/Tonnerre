//
//  ServiceIDTrie.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct ServiceIDTrie {
  private final class Node {
    var children: [Character: Node]
    var values: Heap<String>
    
    init<T: Sequence>(children: [Character: Node], values: T)
      where T.Element == String {
      self.children = children
      self.values = Heap<String>(newElements: values) {
        ProviderMap.shared.getSortingScore(byID: $0)
        >
        ProviderMap.shared.getSortingScore(byID: $1)
      }
    }
    
    init() {
      children = [:]
      values = Heap<String> {
        ProviderMap.shared.getSortingScore(byID: $0)
          >
        ProviderMap.shared.getSortingScore(byID: $1)
      }
    }
  }
  
  private let rootNode: Node
  
  /**
   Insert a value into the trie
   - parameter value: the element needs to be inserted
   */
  mutating func insert(key: String, value: String) {
    if key.isEmpty { return }
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
   Find a list of stored values with given string
   - parameter value: the key with which the elments associate
   - returns: an array of elements that share the same beginning as the `value`
   */
  func find(value: String) -> [String] {
    if value.isEmpty { return rootNode.values.linearStorage }
    var node = rootNode
    for char in value {
      guard let next = node.children[char] else { return [] }
      node = next
    }
    return node.values.linearStorage
  }
  
  mutating func remove(key: String, value: String) {
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
}
