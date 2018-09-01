//
//  DynamicScriptMode.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum DynamicScriptMode {
  case prepare(input: [String])
  case serve(choice: [String: Any])
  
  var argument: String {
    switch self {
    case .prepare(input: _): return "--prepare"
    case .serve(choice: _): return "--serve"
    }
  }
}
