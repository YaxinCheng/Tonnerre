//
//  LaunchOrder+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-17.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import CoreData
import Foundation

extension LaunchOrder {
  static func save(with identifier: String) {
    let context = getContext()
    let launchOrder: LaunchOrder
    if let existing = find(identifier: identifier) {
      launchOrder = existing
    } else {
      launchOrder = LaunchOrder(context: context)
    }
    launchOrder.identifier = identifier
    launchOrder.time = Date()
    do {
      try context.save()
    } catch {
      Logger.error(file: "\(self.self)", "URL Open Error: %{PUBLIC}@", error.localizedDescription)
    }
  }
  
  static func retrieveTime(with identifier: String) -> Date {
    return find(identifier: identifier)?.time ?? Date(timeIntervalSince1970: 0)
  }
  
  static private func find(identifier: String) -> LaunchOrder? {
    let fetchRequest = NSFetchRequest<LaunchOrder>(entityName: "LaunchOrder")
    fetchRequest.predicate = NSPredicate(format: "identifier=%@", identifier)
    fetchRequest.fetchLimit = 1
    let context = getContext()
    return (try? context.fetch(fetchRequest))?.first
  }
}
