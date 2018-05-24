//
//  IndexManage.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-24.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

class IndexManage {
  private static var storedIndexes = [TonnerreIndex?](repeating: nil, count: 3)
  
  subscript(index: SearchMode) -> TonnerreIndex {
    get {
      if let indexFile = IndexManage.storedIndexes[index.storedInt] {
        IndexManage.storedIndexes[index.storedInt] = indexFile
        return indexFile
      } else {
        return TonnerreIndex(filePath: index.indexPath, indexType: index.indexType)
      }
    } set {
      IndexManage.storedIndexes[index.storedInt] = newValue
    }
  }
}
