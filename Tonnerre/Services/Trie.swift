//
//  Trie.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Trie<T> {
  
  private class Node {
    var children: [Character: Node]
    var values: [T]
    
    init(children: [Character: Node], values: [T]) {
      self.children = children
      self.values = values
    }
  }
  
  private var rootNode: Node
  private let getKeyword: (T)->String
  
  init(values: [T], getKeyword: @escaping (T)->String) {
    self.getKeyword = getKeyword
    rootNode = Node(children: [:], values: values)
    for value in values {
      insert(value: value)
    }
  }
  
  func find(value: String) -> [T] {
    if value.isEmpty { return rootNode.values }
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
  
  mutating func insert(value: T) {
    if getKeyword(value).isEmpty { return }
    var node = rootNode
    var lastIndex = -1
    let keyword = getKeyword(value)
    for (index, char) in keyword.enumerated() {
      if let next = node.children[char] {
        node = next
        node.values.append(value)
      } else {
        lastIndex = index
        break
      }
    }
    if lastIndex != -1 {
      let startIndex = keyword.index(keyword.startIndex, offsetBy: lastIndex)
      for char in keyword[startIndex...] {
        node.children[char] = Node(children: [:], values: [value])
        node = node.children[char]!
      }
    }
  }
}

