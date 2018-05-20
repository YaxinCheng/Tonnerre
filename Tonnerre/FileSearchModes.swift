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
    let appSupportPath = UserDefaults.standard.url(forKey: StoredKeys.appSupportDir.rawValue)!
    let indexDirPath = appSupportPath.appendingPathComponent("indices", isDirectory: true)
    let indexPath = indexDirPath.appendingPathComponent(self.rawValue)
    return TonnerreIndex(filePath: indexPath.path, indexType: indexType)
  }
  
  var indexTargets: [URL] {
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    switch self {
    case .defaultMode:
      return [URL(fileURLWithPath: "/Applications"), URL(fileURLWithPath: "/System/Library/PreferencePanes"), homeDir.appendingPathComponent("Application", isDirectory: true)]
    default:
      let exclusions = Set<String>(["Public", "Library", "Applications"])
      do {
        let userDirs = try FileManager.default.contentsOfDirectory(at: homeDir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
        return userDirs.filter({ !exclusions.contains($0.lastPathComponent) })
      } catch {
        return []
      }
    }
  }
}
