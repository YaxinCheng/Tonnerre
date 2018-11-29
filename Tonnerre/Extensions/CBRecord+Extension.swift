//
//  CBRecord+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

extension CBRecord: LimitedDataProtocol {
  static func recordInsert(value: NSAttributedString, type: String, appURL: URL?, limit: Int) {
    removeAll(predicate: NSPredicate(format: "value=%@", value))
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    let context = getContext()
    let count = (try? context.count(for: fetchRequest)) ?? 0
    if count >= limit {
      removeOldest(sortingKey: "time") {
        guard let source = $0.source,
          source.copied?.count == 1 else { return }
        context.delete(source)
      }
    }
    #if RELEASE
    let newObject = CBRecord(context: context)
    newObject.type = type
    newObject.value = value
    newObject.source = CBSource.fetchInstance(by: appURL)
    newObject.time = Date()
    try? context.save()
    #endif
  }
}

extension CBSource {
  static func fetchInstance(by appURL: URL?) -> CBSource? {
    guard let url = appURL else { return nil }
    let fetchRequest = NSFetchRequest<CBSource>(entityName: "CBSource")
    fetchRequest.predicate = NSPredicate(format: "path=%@", argumentArray: [url])
    fetchRequest.fetchLimit = 1
    let context = getContext()
    if
      let fetchedSources = try? context.fetch(fetchRequest),
      let existingSource = fetchedSources.first
    {
      return existingSource
    } else {
      return createInstance(withContext: context, withURL: url)
    }
  }
  
  private static func createInstance(withContext context: NSManagedObjectContext,
                                     withURL url: URL) -> CBSource {
    let newSource = CBSource(context: context)
    newSource.path = url
    return newSource
  }
}
