//
//  AppleScriptServiceProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-04.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Services running based on Apple Script
*/
protocol AppleScriptServiceProtocol: TonnerreService {
  /**
   The script that provides the action
  */
  var script: String { get }
  // TODO: support loading apple script protocol from tne
}

extension AppleScriptServiceProtocol {
  var argLowerBound: Int { return 0 }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard input.count == 0 else { return [] }
    return [self]
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let script = NSAppleScript(source: script) else { return }
    script.executeAndReturnError(nil)
  }
}
