//
//  DisplayOrder.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum DisplayOrder {
  
  private static func levenshteinScore(source: String, target: String) -> UInt8 {
    let distanceToScore: (Int) -> UInt8 = {
      let longerSize = max(source.count, target.count)
      return UInt8((1 - Double($0)/Double(longerSize)) * 100)
    }
    if source.isEmpty { return distanceToScore(target.count) }
    if target.isEmpty { return distanceToScore(source.count) }
    var distance = [[Int]](repeating:
        [Int](repeating: 0, count: source.count + 1)
      , count: target.count + 1)
    for i in 0 ... source.count { distance[0][i] = i }
    for j in 0 ... target.count { distance[j][0] = j }
    for i in 1 ... source.count {
      for j in 1 ... target.count {
        let sourceChar = source[source.index(source.startIndex, offsetBy: i - 1)]
        let targetChar = target[target.index(target.startIndex, offsetBy: j - 1)]
        let score = sourceChar == targetChar ? 0 : 1
        distance[j][i] = min(distance[j - 1][i] + 1, distance[j][i - 1] + 1, distance[j - 1][i - 1] + score)
      }
    }
    let distanceValue = distance.last!.last!
    return distanceToScore(distanceValue)
  }
  
  private static func getLastVisitScore(identifier: String) -> UInt8 {
    let lastVisit = LaunchOrder.retrieveTime(with: identifier)
    let timeDiffScore = 100 + max(lastVisit.timeIntervalSinceNow/(30 * 24 * 60 * 60) * 100, -100)
    return UInt8(timeDiffScore)
  }
  
  static func sortingScore(baseString: String, query: String, timeIdentifier: String) -> UInt8 {
    let keywordScore = baseString.isEmpty ? 50 : levenshteinScore(source: query.lowercased(),
                                                                  target: baseString.lowercased())
    let lastVisiScore = getLastVisitScore(identifier: timeIdentifier)
    return keywordScore + lastVisiScore
  }
  
  
}
