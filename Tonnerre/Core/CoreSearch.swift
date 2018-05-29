//
//  SearchService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

class CoreSearch {
  private let fileManager = FileManager.default
  static var availableModes: [SearchMode] = []
  private let indexStorage = IndexStorage()
  
  init() {
    let context = getContext()
    guard CoreSearch.availableModes.isEmpty else { return }
    do {
      let fetchRequest = NSFetchRequest<AvailableMode>(entityName: CoreDataEntities.AvailableMode.rawValue)
      let modes = try context.fetch(fetchRequest)
      CoreSearch.availableModes = modes.filter({ $0.enabled }).compactMap({ SearchMode(rawValue: $0.name!) })
    } catch {
      NSApplication.shared.presentError(error)
      CoreSearch.availableModes = [.defaultMode, .content, .name]
    }
  }
  
  func search(keyword: String, in mode: SearchMode) -> [URL] {
    guard CoreSearch.availableModes.contains(mode) else { return [] }
    let index = indexStorage[mode]
    return index.search(query: keyword, limit: 9 * 9, options: .defaultOption)
  }
}
