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
  
  var indexPath: URL {
    let appSupportDir = UserDefaults.standard.url(forKey: StoredKeys.appSupportDir.rawValue)!
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
    case .defaultMode: return 0
    case .name: return 1
    case .content: return 2
    }
  }
  
  var indexTargets: [URL] {
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    switch self {
    case .defaultMode:
      return ["/Applications", "/System/Library/PreferencePanes", "/Applications/Xcode.app/Contents/Applications/", "/System/Library/CoreServices/Applications/", "/System/Library/CoreServices/Finder.app"].map({ URL(fileURLWithPath: $0) }) + [homeDir.appendingPathComponent("Applications", isDirectory: true)]
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
  
  func include(fileURL: URL) -> Bool {
    switch self {
    case .defaultMode:
      return FileTypeControl(type: .app).isInControl(file: fileURL) || FileTypeControl(type: .systemPref).isInControl(file: fileURL)
    case .content:
      return FileTypeControl(type: .document).isInControl(file: fileURL) || FileTypeControl(type: .message).isInControl(file: fileURL)
    case .name:
      let types: [FileTypeControl.ControlType] = [.app, .document, .image, .media, .message]
      for each in types.map(FileTypeControl.init) {
        if each.isInControl(file: fileURL) { return true }
      }
      return false
    }
  }
}

