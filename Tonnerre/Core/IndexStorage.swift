//
//  IndexManage.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-24.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

class IndexStorage {
  private static var storedIndexes = [TonnerreIndex?](repeating: nil, count: 3)
  
  subscript(index: SearchMode) -> TonnerreIndex {
    return self[index, false]
  }
  
  subscript(index: SearchMode, writable: Bool) -> TonnerreIndex {
    get {
      if let indexFile = IndexStorage.storedIndexes[index.storedInt] {
        IndexStorage.storedIndexes[index.storedInt] = indexFile
        return indexFile
      } else {
        return TonnerreIndex(filePath: index.indexPath, indexType: index.indexType, writable: writable)!
      }
    } set {
      IndexStorage.storedIndexes[index.storedInt] = newValue
    }
  }
}
