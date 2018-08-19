//
//  QueryHistory+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

extension QueryHistory: LimitedDataProtocol {
  static func queryInsert(identifier: String, query: String, limit: Int, unique: Bool = false) {
    if unique { uniquelize(predicate: NSPredicate(format: "identifier=%@ AND query=%@", identifier, query)) }
    let fetchRequest = NSFetchRequest<QueryHistory>(entityName: "QueryHistory")
    fetchRequest.predicate = NSPredicate(format: "identifier=%@", identifier)
    let context = getContext()
    let count = (try? context.count(for: fetchRequest)) ?? 0
    if count > limit { removeOldest(sortingKey: "time", predicate: NSPredicate(format: "identifier=%@", identifier)) }
    let newHistory = QueryHistory(context: context)
    newHistory.identifier = identifier
    newHistory.query = query
    newHistory.time = Date()
    try? context.save()
  }
}
