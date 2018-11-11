//
//  Heap.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Heap<T: Hashable> {
  private(set) var linearStorage: [T] = []
  private var duplicateAvoider: Set<T> = []
  var compareMethod: (T, T) -> Bool
  var count: Int { return linearStorage.count }
  
  init(compareMethod: @escaping (T, T) -> Bool) {
    self.compareMethod = compareMethod
  }
  
  init<V: Sequence>(newElements: V, compareMethod: @escaping (T, T) -> Bool)
    where V.Element == T {
    self.compareMethod = compareMethod
    add(contentOf: newElements)
  }
  
  mutating func add(_ newElement: T) {
    guard !duplicateAvoider.contains(newElement) else { return }
    duplicateAvoider.insert(newElement)
    linearStorage.append(newElement)
    reorder(from: count - 1)
  }
  
  mutating func add<V: Sequence>(contentOf newElements: V) where V.Element == T {
    for newElement in newElements {
      add(newElement)
    }
  }
  
  mutating func removeFirst() -> T {
    return remove(at: 0)
  }
  
  @discardableResult
  mutating func remove(at index: Int, removeHash: Bool = true) -> T {
    let childrenIndeces = (index * 2 + 1, index * 2 + 2)
    let removedItem: T
    switch childrenIndeces {
    case (_, count...): // one or no leaf
      removedItem = linearStorage.remove(at: index)
    case (..<count, ..<count):// More than one leaves
      removedItem = self[index]
      if compareMethod(self[childrenIndeces.0], self[childrenIndeces.1]) {
        self[index] = self[childrenIndeces.0]
        _ = remove(at: childrenIndeces.0, removeHash: false)
      } else {
        self[index] = self[childrenIndeces.1]
        _ = remove(at: childrenIndeces.1, removeHash: false)
      }
    default: fatalError("Never should get here")
    }
    duplicateAvoider.remove(removedItem)
    return removedItem
  }
  
  func find(element: T, startingIndex: Int = 0) -> Int {
    let item = self[startingIndex]
    if item == element { return startingIndex }
    else if compareMethod(element, item) { return -1 }
    else {
      let leftSide  = find(element: element, startingIndex: startingIndex * 2 + 1)
      let rightSide = find(element: element, startingIndex: startingIndex * 2 + 2)
      return Swift.max(leftSide, rightSide)
    }
  }
  
  @discardableResult
  mutating func remove(element: T) -> T {
    let elementIndex = find(element: element)
    return remove(at: elementIndex)
  }
  
  mutating func reorder(from index: Int) {
    guard index > 0 else { return }
    let parentIndex = (index - 1) / 2
    if compareMethod(self[parentIndex], self[index]) == true {
      return
    } else {
      (self[parentIndex], self[index]) =
        (self[index], self[parentIndex])
      reorder(from: parentIndex)
    }
  }
}

extension Heap: Collection {
  var startIndex: Int { return 0 }
  var endIndex: Int { return linearStorage.count }
  func index(after i: Int) -> Int { return i + 1 }
  subscript(position: Int) -> T {
    get {
      return linearStorage[position]
    } set {
      linearStorage[position] = newValue
    }
  }
}

extension Heap: CustomStringConvertible {
  var description: String {
    return linearStorage.description
  }
}
