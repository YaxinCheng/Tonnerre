//
//  IndexManage.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-24.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

struct IndexStorage {
  private static var storedIndexes = [TonnerreIndex?](repeating: nil, count: 3)
  private static var readonlyIndexes = [TonnerreIndex?](repeating: nil, count: 3)
  
  subscript(index: SearchMode) -> TonnerreIndex {
    if let indexFile = IndexStorage.readonlyIndexes[index.storedInt] {
      return indexFile
    } else {
      let tnIndex = TonnerreIndex(filePath: index.indexFileURL, indexType: index.indexType, writable: false)!
      IndexStorage.readonlyIndexes[index.storedInt] = tnIndex
      return tnIndex
    }
  }
  
  subscript(index: SearchMode, writable: Bool) -> TonnerreIndex {
    get {
      guard writable else { return self[index] }
      if let indexFile = IndexStorage.storedIndexes[index.storedInt] {
        return indexFile
      } else {
        let tnIndex = TonnerreIndex(filePath: index.indexFileURL, indexType: index.indexType, writable: writable)!
        IndexStorage.storedIndexes[index.storedInt] = tnIndex
        return tnIndex
      }
    } set {
      guard writable else { return }
      IndexStorage.storedIndexes[index.storedInt] = newValue
    }
  }
}
