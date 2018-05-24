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
  
  subscript(index: SearchMode) -> TonnerreIndex? {
    get {
      return IndexManage.storedIndexes[index.storedInt]
    } set {
      IndexManage.storedIndexes[index.storedInt] = newValue
    }
  }
}
