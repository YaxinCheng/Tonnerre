//
//  LimitedDataProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import CoreData

protocol LimitedDataProtocol {
}

extension LimitedDataProtocol {
  static func removeOldestEntries(
                           count: Int = 1,
                           sortingKey: String,
                           predicate: NSPredicate? = nil
                           ) {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "\(Self.self)")
    fetchRequest.predicate = predicate
    fetchRequest.fetchLimit = count
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortingKey, ascending: true)]
    let context = getContext()
    guard let fetchedData = (try? context.fetch(fetchRequest))?.first as? Self else { return }
    context.delete(fetchedData as! NSManagedObject)
    do {
      try context.save()
    } catch {
      #if DEBUG
      print(error)
      #endif
    }
  }
  
  static func removeAll(predicate: NSPredicate) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(Self.self)")
    fetchRequest.predicate = predicate
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    let context = getContext()
    do {
      try context.execute(deleteRequest)
      try context.save()
    } catch {
      #if DEBUG
      print(error)
      #endif
    }
  }
}
