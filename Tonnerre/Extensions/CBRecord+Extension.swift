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
    if count >= limit { removeOldest(sortingKey: "time") }
    let newObject = CBRecord(context: context)
    newObject.type = type
    newObject.value = value
    newObject.application = appURL
    newObject.time = Date()
    #if RELEASE
    try? context.save()
    #endif
  }
}
