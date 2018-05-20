//
//  FileSearchManager.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

class FileSearchManager {
  private static var instance: FileSearchManager! = nil
  private let fileManager = FileManager.default
  var availableModes: [SearchMode]
  private let indexingManager: FileIndexingManager
  
  init() {
    let context = getContext()
    indexingManager = FileIndexingManager()
    do {
      let fetchRequest = NSFetchRequest<AvailableMode>(entityName: CoreDataEntities.AvailableMode.rawValue)
      let modes = try context.fetch(fetchRequest)
      availableModes = modes.filter({ $0.enabled }).compactMap({ SearchMode(rawValue: $0.name!) })
    } catch {
      NSApplication.shared.presentError(error)
      availableModes = []
    }
  }
  
  static var shared: FileSearchManager {
    if instance == nil {
      instance = FileSearchManager()
    }
    return instance
  }
  
  func check() {
    let context = getContext()
    do {
      let fetchRequest = NSFetchRequest<IndexedDir>(entityName: CoreDataEntities.IndexedDir.rawValue)
      let indexedCount = try context.count(for: fetchRequest)
      if indexedCount == 0 {
        createIndexFiles()
        fullIndexing()
      } else {
        complementaryIndexing()
      }
    } catch {
      NSApplication.shared.presentError(error)
    }
  }
  
  private func createIndexFiles() {
    _ = availableModes.map({ createIndexFile(name: $0.rawValue, type: $0.indexType) })
  }
  
  func createIndexFile(name: String, type: TonnerreIndexType) -> TonnerreIndex {
    let appSupportDir = UserDefaults.standard.url(forKey: StoredKeys.appSupportDir.rawValue)!
    let indecesFolder = appSupportDir.appendingPathComponent("Indeces")
    do {
      if !fileManager.fileExists(atPath: indecesFolder.path) {
        try fileManager.createDirectory(at: indecesFolder, withIntermediateDirectories: true, attributes: nil)
      }
    } catch { NSApplication.shared.presentError(error) }
    let filePath = indecesFolder.appendingPathComponent(name)
    return TonnerreIndex(filePath: filePath.path, indexType: type)
  }
  
  /**
   Initial full indexing from the beginning. Index every possible file
  */
  private func fullIndexing() {
    //TODO
  }
  
  /**
   Add-on indexing. Only modify the changes in the index files
  */
  private func complementaryIndexing() {
    //TODO
  }
}
