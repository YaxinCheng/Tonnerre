//
//  DisplayPriority.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum DisplayPriority {
  case high
  case normal
  case low
  
  init?(rawValue: String) {
    switch rawValue.lowercased() {
    case "high":   self = .high
    case "normal": self = .normal
    case "low":    self = .low
    default: return nil
    }
  }
}
