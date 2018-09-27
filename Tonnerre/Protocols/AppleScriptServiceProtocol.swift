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
   The script that provides the service
  */
  var script: String { get }
}

extension AppleScriptServiceProtocol {
  var argLowerBound: Int { return 0 }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard input.count == 0 else { return [] }
    return [self]
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let script = NSAppleScript(source: script) else { return }
    var error: NSDictionary? = nil
    script.executeAndReturnError(&error)
    #if DEBUG
    if error != nil {
      print(error!)
    }
    #endif
  }
}
