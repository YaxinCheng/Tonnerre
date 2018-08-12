//
//  Trie.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Trie is an time efficient data structure used to search and complete words based on the beginning characters
*/
struct Trie<T> {
  
  /**
   Nodes are chained together like a linked list.
   Each of them represents a state where all values share the same beginning characters
  */
  private class Node {
    /**
     The next nodes based on the next character
    */
    var children: [Character: Node]
    /**
     All the elements that share the same characters in from beginning
    */
    var values: [T]
    
    init(children: [Character: Node], values: [T]) {
      self.children = children
      self.values = values
    }
  }
  
  /**
   The node which contains every element in this trie
  */
  private var rootNode: Node
  /**
   The function how the trie should retrieve a keyword from the given element
  */
  private let getKeyword: (T)->String
  
  /**
   Construct a tries with given elements and a related key retrieve function
   - parameter values: an array of elements need to be stored in the trie
   - parameter getKeyword: a function applies to one element and retrieve the related keyword
  */
  init(values: [T], getKeyword: @escaping (T)->String) {
    self.getKeyword = getKeyword
    rootNode = Node(children: [:], values: values)
    for value in values {
      insert(value: value)
    }
  }
  
  /**
   Find a list of stored values with given string
   - parameter value: the key with which the elments associate
   - returns: an array of elements that share the same beginning as the `value`
  */
  func find(value: String) -> [T] {
    if value.isEmpty { return rootNode.values }
    var node = rootNode
    for char in value {
      guard let next = node.children[char] else { return [] }
      node = next
    }
    return node.values
  }
  
  /**
   Insert a value into the trie
   - parameter value: the element needs to be inserted
  */
  mutating func insert(value: T) {
    if getKeyword(value).isEmpty { return }
    var node = rootNode
    let keyword = getKeyword(value)
    var index = keyword.startIndex
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
}

