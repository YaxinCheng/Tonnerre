//
//  QueryStack.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-12.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

class QueryStack<T> {
  private var queryStack: [T?]
  let limit: Int
  private var top: Int = 0
  
  init(size: Int) {
    limit = size
    queryStack = [T?](repeating: nil, count: size)
  }
  
  func pop() -> T? {
    if let value = queryStack[top] {
      top = (top - 1 + limit) % limit
      return value
    }
    return nil
  }
  
  func append(value: T) {
    queryStack[top] = value
    top = (top + 1) % limit
  }
  
  func contains(standard: (T)->Bool) -> Bool {
    for each in queryStack where each != nil {
      if standard(each!) == true { return true }
    }
    return false
  }
  
  func values() -> [T] {
    var iter = (top - 1 + limit) % limit
    var count = 0
    var result = [T]()
    while count < limit {
      if let value = queryStack[iter] {
        result.append(value)
      } else { break }
      iter = (iter + limit - 1) % limit
      count += 1
    }
    return result
  }
}
