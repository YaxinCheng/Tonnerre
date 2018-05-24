//
//  SearchService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

class SearchService {
  private let fileManager = FileManager.default
  var availableModes: [SearchMode]
  private let indexingManager: CoreIndexing
  
  init() {
    let context = getContext()
    do {
      let fetchRequest = NSFetchRequest<AvailableMode>(entityName: CoreDataEntities.AvailableMode.rawValue)
      let modes = try context.fetch(fetchRequest)
      availableModes = modes.filter({ $0.enabled }).compactMap({ SearchMode(rawValue: $0.name!) })
    } catch {
      NSApplication.shared.presentError(error)
      availableModes = [.defaultMode, .content, .name]
    }
    let detectingPath = Set(availableModes.map({ $0.indexTargets }).reduce([], +)).map({ $0.path })
    indexingManager = CoreIndexing(listen: Array(detectingPath))
  }

  
  func check() {
    let defaultFinished = UserDefaults.standard.bool(forKey: StoredKeys.defaultInxFinished.rawValue)
    let documentFinished = UserDefaults.standard.bool(forKey: StoredKeys.documentInxFinished.rawValue)
    if defaultFinished == false && documentFinished == false {
      let context = getContext()
      let fetchRequest = NSFetchRequest<IndexingDir>(entityName: CoreDataEntities.IndexingDir.rawValue)
      let count = (try? context.count(for: fetchRequest)) ?? 0
      if count == 0 {
        fullIndexing()
      } else {
        complementaryIndexing()
      }
    }
    listeningToChanges()
  }
  
  /**
   Initial full indexing from the beginning. Index every possible file
  */
  private func fullIndexing() {
//    Add target paths here for both
    indexingManager.fullIndex(modes: .defaultMode)
    indexingManager.fullIndex(modes: .name, .content)
  }
  /**
   When error happend in the indexing process, we re-index what we left based on the CoreData.IndexingDir 
  */
  private func complementaryIndexing() {
    indexingManager.recoverFromErrors()
  }
  
  /**
   Add-on indexing. Only modify the changes in the index files
  */
  private func listeningToChanges() {
    indexingManager.listenToChanges()
  }
}
