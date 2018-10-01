//
//  String+fill.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension String {
  /**
   Fill in parameters into the given string template
   - parameter args: arguments used to replace the placeholders
   - parameter separator: a separator used to join all components. " " by default
   - returns: a new string with the placeholders replaced by the arguments.
   
   - If the number of arguments is more than the number of placeholders, then the last a few arguments will be joined to one to fill one placeholder.
   - If the number of arguments is less than the number of placeholders, then the template will be returned without filling.
   */
  func filled(arguments args: [String], separator: String = " ") -> String {
    let placeholderCount = components(separatedBy: "%@").count - 1
    guard placeholderCount <= args.count, placeholderCount > 0 else { return self }
    if placeholderCount == args.count {
      return String(format: self, arguments: args)
    } else {
      let lastArg = args[(placeholderCount - 1)...].joined(separator: separator)
      let fillInArgs = Array(args[..<(placeholderCount - 1)]) + [lastArg]
      return String(format: self, arguments: fillInArgs)
    }
  }

}
