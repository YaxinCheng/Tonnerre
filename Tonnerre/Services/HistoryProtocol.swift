//
//  HistoryProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData

protocol HistoryProtocol {
  var identifier: String { get }
  var historyLimit: Int { get }
  func appendHistory(query: String, unique: Bool)
  func histories() -> [String]
  func reuse(history: [String]) -> [Displayable]
}

extension HistoryProtocol {
  func appendHistory(query: String, unique: Bool = false) {
    QueryHistory.queryInsert(identifier: identifier, query: query, limit: historyLimit, unique: unique)
  }
  
  func histories() -> [String] {
    let fetchRequest = NSFetchRequest<QueryHistory>(entityName: "QueryHistory")
    fetchRequest.predicate = NSPredicate(format: "identifier=%@", identifier)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
    let context = getContext()
    do {
      let fetchedData = try context.fetch(fetchRequest)
      return fetchedData.map { $0.query! }
    } catch {
      #if DEBUG
      print(error)
      #endif
      return []
    }
  }
}
