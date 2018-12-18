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
  static func recordInsert(value: NSAttributedString, type: String, limit: Int) {
    removeAll(predicate: NSPredicate(format: "value=%@", value))
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    let context = getContext()
    let count = (try? context.count(for: fetchRequest)) ?? 0
    if count >= limit { removeOldestEntries(count: limit, sortingKey: "time") }
    #if RELEASE
    let newObject = CBRecord(context: context)
    newObject.type = type
    newObject.value = value
    newObject.time = Date()
    try? context.save()
    #endif
  }
}
