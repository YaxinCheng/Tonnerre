//
//  QueryStack.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-12.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct QueryStack {
  private var queryStack: [String?]
  let limit: Int
  private var top: Int = 0
  
  init(size: Int) {
    limit = size
    queryStack = [String?](repeating: nil, count: size)
  }
  
  mutating func pop() -> String? {
    if let value = queryStack[top] {
      top = (top - 1 + limit) % limit
      return value
    }
    return nil
  }
  
  mutating func append(query: String) {
    queryStack[top] = query
    top = (top + 1) % limit
  }
}
