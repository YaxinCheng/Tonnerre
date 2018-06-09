//
//  Trie.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Trie {
  
  class Node {
    var children: [Character: Node]
    var values: Set<String>
    
    init(children: [Character: Node], values: Set<String>) {
      self.children = children
      self.values = values
    }
  }
  
  var rootNode: Node
  
  init(values: Set<String>) {
    rootNode = Node(children: [:], values: [])
    values.forEach(insert)
  }
  
  func find(value: String) -> Set<String> {
    if value.isEmpty { return [] }
    var node = rootNode
    for char in value {
      if let next = node.children[char] {
        node = next
      } else {
        return []
      }
    }
    return node.values
  }
  
  func insert(value: String) {
    if value.isEmpty { return }
    var node = rootNode
    var lastIndex = -1
    for (index, char) in value.enumerated() {
      if let next = node.children[char] {
        node = next
        node.values.insert(value)
      } else {
        lastIndex = index
        break
      }
    }
    if lastIndex != -1 {
      let startIndex = value.index(value.startIndex, offsetBy: lastIndex)
      for char in value[startIndex...] {
        node.children[char] = Node(children: [:], values: [value])
        node = node.children[char]!
      }
    }
    node.values.insert(value)
  }
}

