//
//  FileSearchModes.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

enum SearchMode: String {
  case defaultMode
  case name
  case content
  
  var indexType: TonnerreIndexType {
    switch self {
    case .content: return .metadata
    default: return .nameOnly
    }
  }
  
  var index: TonnerreIndex {
    return indexStorage[self]!
  }
  
  var includeDir: Bool {
    return self == .name
  }
  
  /**
   Value used to identify the type in CoreData
  */
  var storedInt: Int {
    switch self {
    case .defaultMode: return 0
    case .name: return 1
    case .content: return 2
    }
  }
  
  var indexTargets: [URL] {
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    switch self {
    case .defaultMode:
      return [URL(fileURLWithPath: "/Applications"), URL(fileURLWithPath: "/System/Library/PreferencePanes"), homeDir.appendingPathComponent("Applications", isDirectory: true)]
    default:
      return ["Downloads", "Desktop", "Documents", "Library/Mobile Documents/com~apple~CloudDocs"].map(homeDir.appendingPathComponent)
    }
  }
  
  static func setIndexStorage(data: [SearchMode: TonnerreIndex]) {
    if indexStorage.isEmpty {
      indexStorage = data
    }
  }
}

fileprivate var indexStorage: [SearchMode: TonnerreIndex] = [:]
