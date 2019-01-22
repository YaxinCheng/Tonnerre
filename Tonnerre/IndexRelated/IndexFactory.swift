//
//  IndexFactory.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-01-04.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

struct IndexFactory {
  enum IndexOption: String {
    case `default`
    case name
    case content
    
    var filePath: URL {
      let indecesFolder = SupportFolders.indices.path
      return indecesFolder.appendingPathComponent(rawValue + ".tnidx")
    }
  }
  
  private static func load(index: IndexOption) -> TonnerreIndex? {
    return try? TonnerreIndex.open(path: index.filePath)
  }
  
  static var `default`: TonnerreIndex? {
    return load(index: .default)
  }
  
  static var name: TonnerreIndex? {
    return load(index: .name)
  }
  
  static var content: TonnerreIndex? {
    return load(index: .content)
  }
}
