//
//  String+match.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-26.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension String {
  func match(regex: NSRegularExpression) -> Substring? {
    guard
      let firstMatch = regex.firstMatch(in: self, options: .withoutAnchoringBounds, range: NSRange(location: 0, length: self.count))
    else { return nil }
    return self[Range(firstMatch.range, in: self)!]
  }
}
