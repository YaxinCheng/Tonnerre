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
  case `default`
  case name
  case content
  
  var indexType: TonnerreIndexType {
    switch self {
    case .content: return .metadata
    default: return .nameOnly
    }
  }
  
  var indexPath: URL {
    let userDefault = UserDefaults(suiteName: "Tonnerre")!
    let appSupportDir = userDefault.url(forKey: StoredKeys.appSupportDir.rawValue)!
    let indecesFolder = appSupportDir.appendingPathComponent("Indices")
    return indecesFolder.appendingPathComponent(self.rawValue + ".tnidx")
  }
  
  var includeDir: Bool {
    return self == .name
  }
  
  /**
   Value used to identify the type in CoreData
  */
  var storedInt: Int {
    switch self {
    case .default: return 0
    case .name: return 1
    case .content: return 2
    }
  }
  
  var indexTargets: [URL] {
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    switch self {
    case .default:
      return [homeDir.appendingPathComponent("Applications")] + ["/System/Library/CoreServices/Finder.app", "/System/Library/CoreServices/Applications", "/System/Library/PreferencePanes", "/Applications"].map { URL(fileURLWithPath: $0) }
    default:
      let exclusions = Set(["Public", "Library", "Applications"])
      do {
        let userDirs = try FileManager.default.contentsOfDirectory(at: homeDir, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants])
        return userDirs.filter { !exclusions.contains($0.lastPathComponent) }
      } catch {
        return []
      }
    }
  }
  
  func include(fileURL: URL) -> Bool {
    switch self {
    case .default:
      return FileTypeControl(types: .app, .systemPref).isInControl(file: fileURL)
    case .content:
      return FileTypeControl(types: .document, .message).isInControl(file: fileURL)
    case .name:
      return true
    }
  }
}

