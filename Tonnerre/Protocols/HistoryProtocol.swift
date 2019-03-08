//
//  HistoryProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData

/**
 Any service needs to store query history should conforms to this protocol
*/
protocol HistoryProtocol {
  /**
   Service identifier used to store history data into the db.
   - Warning: must be unique
  */
  var identifier: String { get }
  /**
   The number of history records must be lower than this number
  */
  var historyLimit: Int { get }
  /**
   Append the query into history db
   - parameter query: the query needs to be stored
   - parameter unique: if true, remove all other records with the same query, and keep this as the only one
  */
  func appendHistory(query: String, unique: Bool)
  /**
   Retrieve history records from db
   - returns: An array of history records string
  */
  func histories() -> [String]
}

extension HistoryProtocol {
  func appendHistory(query: String, unique: Bool = false) {
    guard historyLimit > 0 else { return }
    QueryHistory.insert(identifier: identifier, query: query, limit: historyLimit, unique: unique)
  }
  
  func histories() -> [String] {
    guard historyLimit > 0 else { return [] }
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
