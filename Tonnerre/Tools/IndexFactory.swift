//
//  IndexFactory.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-01-04.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

/// The single location to get TonnerreIndex for Tonnerre
enum IndexFactory {
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
  
  /// Default index. Used by LaunchService
  static weak var `default`: TonnerreIndex? {
    return load(index: .default)
  }
  
  /// Name index. Used by FileNameSearchService
  static weak var name: TonnerreIndex? {
    return load(index: .name)
  }
  
  /// Content index. Used by FileContentSearchService
  static weak var content: TonnerreIndex? {
    return load(index: .content)
  }
}
