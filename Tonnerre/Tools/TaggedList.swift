//
//  ManagedList.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol TaggedListDelegate: class {
  /// Call back function when the number of elements in the list is changed
  ///
  /// - parameter index: from which index, the list increased/decreased
  func listDidChange(from index: Int)
}

final class TaggedList<T: Hashable> {
  private var storage: [[T]] = []
  private var tagToIndex: [T : Int] = [:]
  
  private class IndexCache {
    var prevRequest: Int
    var prevGroup: Int
    var prevItem: Int
    
    init(prevRequest: Int = -1, prevGroup: Int = -1, prevItem: Int = -1) {
      self.prevRequest = prevRequest
      self.prevGroup = prevGroup
      self.prevItem = prevItem
    }
  }
  private var cache = IndexCache()
  var lock: DispatchSemaphore?
  
  weak var delegate: TaggedListDelegate?
  
  func append<C: Collection>(at tag: T, elements: C) where C.Element == T {
    lock?.wait()
    if let index = tagToIndex[tag] {
      storage[index] += Array(elements)
      delegate?.listDidChange(from: (0..<index).map { storage[$0].count }.reduce(0, +))
    } else {
      tagToIndex[tag] = storage.count
      storage.append([tag] + Array(elements))
      delegate?.listDidChange(from: storage.count)
    }
    lock?.signal()
  }
  
  func replace<C: Collection>(at tag: T, elements: C) where C.Element == T {
    lock?.wait()
    if let index = tagToIndex[tag] {
      storage[index] = Array(elements)
      delegate?.listDidChange(from: (0..<index).map { storage[$0].count }.reduce(0, +))
    } else {
      tagToIndex[tag] = storage.count
      storage.append(Array(elements))
      delegate?.listDidChange(from: storage.count)
    }
    lock?.signal()
  }
  
  var last: T? {
    if endIndex > self.count { return nil }
    return self[endIndex - 1]
  }
  
  subscript(tag: T) -> [T] {
    guard
      let index = tagToIndex[tag],
      index < storage.count
    else { return [] }
    return storage[index]
  }
}

extension TaggedList: ExpressibleByArrayLiteral {
  convenience init(arrayLiteral elements: T...) {
    self.init(array: elements)
  }
  
  convenience init(array elements: [T]) {
    self.init()
    for (index, element) in elements.enumerated() {
      storage.append([element])
      tagToIndex[element] = index
    }
  }
  
  convenience init(array elements: [T], filter: (T)->Bool) {
    self.init()
    for (index, element) in elements.enumerated() {
      if filter(element) == true {
        storage.append([element])
      } else {
        storage.append([])
      }
      tagToIndex[element] = index
    }
  }
}

extension TaggedList: Collection {
  subscript(position: Int) -> T {
    let diff = cache.prevRequest < 0 ? .min : position - cache.prevRequest
    var (group, item): (Int, Int)
    if fabs(Double(diff)) == 1 {
      if cache.prevItem == 0 && diff == -1 {
        (group, item) = (cache.prevGroup - 1, storage[cache.prevGroup - 1].count - 1)
        while item < 0 { (group, item) = (group - 1, storage[group - 1].count - 1) }
      } else if cache.prevItem == storage[cache.prevGroup].count - 1
        && diff == 1 {
        (group, item) = (cache.prevGroup + 1, 0)
        while storage[group].count <= 0 { group += 1 }
      } else {
        (group, item) = (cache.prevGroup, cache.prevItem + diff)
      }
    } else {
      var (searchGroup, cummulations) = (-1, 0)
      while cummulations <= position {
        searchGroup += 1
        cummulations += storage[searchGroup].count
      }
      (group, item) = (searchGroup,
                       position - cummulations + storage[searchGroup].count)
    }
    (cache.prevRequest, cache.prevGroup, cache.prevItem) = (position, group, item)
    return storage[group][item]
  }
  
  var startIndex: Int { return 0 }
  
  var endIndex: Int {
    return storage.map { $0.count }.reduce(0, +)
  }
  
  func index(after i: Int) -> Int {
    return i + 1
  }
}
