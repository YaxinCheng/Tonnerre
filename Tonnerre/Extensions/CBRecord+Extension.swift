//
//  CBRecord+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

extension CBRecord {
  static func recordInsert(value: String, type: String, limit: Int) {
    uniquelize(value: value)
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    let context = getContext()
    let count = (try? context.count(for: fetchRequest)) ?? 0
    if count >= limit { removeOldest() }
    let newObject = CBRecord(context: context)
    newObject.type = type
    newObject.value = value
    newObject.time = Date()
    #if RELEASE
    try? context.save()
    #endif
  }
  
  private static func removeOldest() {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CBRecord")
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
  
  private static func uniquelize(value: String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CBRecord")
    fetchRequest.predicate = NSPredicate(format: "value=%@", value)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    let context = getContext()
    try! context.execute(deleteRequest)
    try! context.save()
  }
}
