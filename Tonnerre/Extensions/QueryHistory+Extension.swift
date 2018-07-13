//
//  QueryHistory+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

extension QueryHistory {
  static func queryInsert(identifier: String, query: String, limit: Int, unique: Bool = false) {
    if unique { uniquelize(identifier: identifier, query: query) }
    let fetchRequest = NSFetchRequest<QueryHistory>(entityName: "QueryHistory")
    fetchRequest.predicate = NSPredicate(format: "identifier=%@", identifier)
    let context = getContext()
    let count = (try? context.count(for: fetchRequest)) ?? 0
    if count > limit { removeOldest(identifier: identifier) }
    let newHistory = QueryHistory(context: context)
    newHistory.identifier = identifier
    newHistory.query = query
    newHistory.time = Date()
    try? context.save()
  }
  
  private static func removeOldest(identifier: String) {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "QueryHistory")
    fetchRequest.predicate = NSPredicate(format: "identifier=%@", identifier)
    fetchRequest.fetchLimit = 1
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
    let context = getContext()
    guard let fetchedData = (try? context.fetch(fetchRequest))?.first else { return }
    context.delete(fetchedData)
    do {
      try context.save()
    } catch {
      #if DEBUG
      print(error)
      #endif
    }
  }
  
  private static func uniquelize(identifier: String, query: String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueryHistory")
    fetchRequest.predicate = NSPredicate(format: "identifier=%@ AND query=%@", identifier, query)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    let context = getContext()
    try! context.execute(deleteRequest)
    try! context.save()
  }
}
