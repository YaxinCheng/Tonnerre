//
//  LimitedDataProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import CoreData

/// Used with NSManagedObject providing functions to manage
/// the number of data records
/// - warning: implements this protocol to non-NSManagedObject
///           will crash the program
protocol LimitedDataProtocol: class {
}

extension LimitedDataProtocol {
  /// Remove the number of oldest data entries
  /// - parameter count: the number of entries sorted by
  ///                   creation time
  /// - parameter sortingKey: the date attribute name that
  ///                   sorting depends on
  /// - parameter predicate: a predicate to limit the data
  ///                   to a certain subset
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
      Logger.error(file: Self.self, "Remove Oldest Save Error: %{PUBLIC}@", error.localizedDescription)
    }
  }
  
  /// Remove all data records with given predicate
  /// - parameter predicate: groups the data that needs to be removed
  static func removeAll(predicate: NSPredicate) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(Self.self)")
    fetchRequest.predicate = predicate
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    let context = getContext()
    do {
      try context.execute(deleteRequest)
      try context.save()
    } catch {
      Logger.error(file: Self.self, "Remove All Error: %{PUBLIC}@", error.localizedDescription)
    }
  }
}
