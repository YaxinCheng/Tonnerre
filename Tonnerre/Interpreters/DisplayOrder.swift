//
//  DisplayOrder.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct DisplayOrder {
  private static func findLongestMatchScore(of baseString: String, withPattern pattern: String) -> UInt8 {
    let gain = Double(pattern.count) / Double(baseString.count)
    let lose = baseString.lowercased().starts(with: pattern.lowercased()) ? -0.1 : 0.1
    return UInt8(min(max((gain - lose) * 100, 0), 100))
  }
  
  private static func getLastVisitScore(identifier: String) -> UInt8 {
    let lastVisit = LaunchOrder.retrieveTime(with: identifier)
    let timeDiffScore = 100 + max(lastVisit.timeIntervalSinceNow / 60, -100)
    return UInt8(timeDiffScore)
  }
  
  static func sortingScore(baseString: String, query: String, timeIdentifier: String) -> UInt8 {
    let keywordScore = baseString.isEmpty ? 50 : findLongestMatchScore(of: baseString, withPattern: query)
    let lastVisiScore = getLastVisitScore(identifier: timeIdentifier)
    return keywordScore + lastVisiScore
  }
  
  static func updateSortingScore(timeIdentifier: String) {
    LaunchOrder.save(with: timeIdentifier)
  }
}
