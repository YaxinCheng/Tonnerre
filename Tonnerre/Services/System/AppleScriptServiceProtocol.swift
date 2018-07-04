//
//  AppleScriptServiceProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-04.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol AppleScriptServiceProtocol: TonnerreService {
  var script: String { get }
}

extension AppleScriptServiceProtocol {
  var argLowerBound: Int { return 0 }
  
  func prepare(input: [String]) -> [Displayable] {
    guard input.count == 0 else { return [] }
    return [self]
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let script = NSAppleScript(source: script) else { return }
    script.executeAndReturnError(nil)
  }
}
