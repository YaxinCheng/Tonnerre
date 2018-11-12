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
  
  subscript(index: SearchMode) -> TonnerreIndex {
    return self[index, false]
  }
  
  subscript(index: SearchMode, writable: Bool) -> TonnerreIndex {
    get {
      if let indexFile = IndexStorage.storedIndexes[index.storedInt] {
        return indexFile
      } else {
        let tnIndex = TonnerreIndex(filePath: index.indexFileURL, indexType: index.indexType, writable: writable)!
        IndexStorage.storedIndexes[index.storedInt] = tnIndex
        return tnIndex
      }
    } set {
      IndexStorage.storedIndexes[index.storedInt] = newValue
    }
  }
}
