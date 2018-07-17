//
//  LaunchOrder+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-17.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import CoreData
import Foundation

extension LaunchOrder {
  static func order(identifier: String) {
    let context = getContext()
    let launchOrder: LaunchOrder
    if let existing = find(identifier: identifier) {
      launchOrder = existing
    } else {
      launchOrder = LaunchOrder(context: context)
      launchOrder.identifier = identifier
      launchOrder.score = 9
    }
    launchOrder.pileupScore()
  }
  
  static private func find(identifier: String) -> LaunchOrder? {
    let fetchRequest = NSFetchRequest<LaunchOrder>(entityName: "LaunchOrder")
    fetchRequest.predicate = NSPredicate(format: "identifier=%@", identifier)
    fetchRequest.fetchLimit = 1
    let context = getContext()
    return (try? context.fetch(fetchRequest))?.first
  }
  
  private func pileupScore() {
    let inc: (Int16)->(Int16) = {
      let step = $0 == 9 ? 0 : 9 - $0 % 9
      return 9 - 1 - (-1 + Int16(sqrt(Float(1 + 8 * step)))) / 2
    }// Generate sequence 9, 9 + 8, 9 + 8 + 7, 9 + 8 + 7 + 6, ..., 9 + 8 + 7 + ... + 1 + 0 + 0 + ... + 0
    score += inc(score)
  }
}
