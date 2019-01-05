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
      let userDefault = UserDefaults.shared
      let appSupportDir = userDefault.url(forKey: .appSupportDir)!
      let indecesFolder = appSupportDir.appendingPathComponent("Indices")
      return indecesFolder.appendingPathComponent(rawValue + ".tnidx")
    }
    
    var indexType: TonnerreIndexType {
      switch self {
      case .content: return .metadata
      default: return .nameOnly
      }
    }
  }
  
  private static func load(index: IndexOption) -> TonnerreIndex? {
    return TonnerreIndex(filePath: index.filePath,
                         indexType: index.indexType)
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
