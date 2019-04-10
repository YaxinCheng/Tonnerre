//
//  Logger.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-04-05.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation
import os.log

enum Logger {
  private static let bundleId = Bundle.main.bundleIdentifier ?? "Tonnerre"
  
  static func info(file: Any.Type, _ message: StaticString, _ args: CVarArg...) {
    let logger = OSLog(subsystem: bundleId, category: "\(file)")
    os_log(.info, log: logger, message, args)
  }
  
  static func debug(file: Any.Type, _ message: StaticString, _ args: CVarArg ...) {
    let logger = OSLog(subsystem: bundleId, category: "\(file)")
    os_log(.debug, log: logger, message, args)
  }
  
  static func error(file: Any.Type, _ message: StaticString, _ args: CVarArg ...) {
    let logger = OSLog(subsystem: bundleId, category: "\(file)")
    os_log(.error, log: logger, message, args)
  }
  
}
