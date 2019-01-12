//
//  IndexStorage.swift
//  TonnerreIndexHelper
//
//  Created by Yaxin Cheng on 2019-01-07.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

struct IndexStorage {
  private var storageMap: [SearchMode: TonnerreIndex] = [:]
  
  subscript(key: SearchMode) -> TonnerreIndex? {
    get {
      return storageMap[key]
    } set {
      storageMap[key] = newValue
    }
  }
  
  mutating func populate(_ mode: SearchMode) {
    let fileExists = FileManager.default.fileExists(atPath: mode.indexFileURL.path)
    if fileExists {
      storageMap[mode] = try? TonnerreIndex.open(path: mode.indexFileURL, mode: .writeAndRead)
    } else {
      storageMap[mode] = try? TonnerreIndex.create(path: mode.indexFileURL)
    }
  }
}
