//
//  ManagedList.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class ManagedList<T: Hashable> {
  private var storage: [[T]] = []
  private var indices: [T : Int] = [:]
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
  var listExpanded: ((_ fromIndex: Int) -> Void)?
  
  func append<C: Collection>(at item: T, elements: C) where C.Element == T {
    lock?.wait()
    if let index = indices[item] {
      storage[index] += Array(elements)
      listExpanded?((0..<index).map { storage[$0].count }.reduce(0, +))
    } else {
      indices[item] = storage.count
      storage.append(Array(elements))
      listExpanded?(storage.count)
    }
    lock?.signal()
  }
  
  func replace<C: Collection>(at item: T, elements: C) where C.Element == T {
    lock?.wait()
    if let index = indices[item] {
      storage[index] = Array(elements)
      listExpanded?((0..<index).map { storage[$0].count }.reduce(0, +))
    } else {
      indices[item] = storage.count
      storage.append(Array(elements))
      listExpanded?(storage.count)
    }
    lock?.signal()
  }
  
  func peak(at item: T) -> [T]? {
    if let index = indices[item] {
      return storage[index]
    } else { return nil }
  }
}

extension ManagedList: ExpressibleByArrayLiteral {
  convenience init(arrayLiteral elements: T...) {
    self.init(array: elements)
  }
  
  convenience init(array elements: [T]) {
    self.init()
    for (index, element) in elements.enumerated() {
      storage.append([element])
      indices[element] = index
    }
  }
}

extension ManagedList: Collection {
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
