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
  
  static let CMD: String = "⌘"
  
  /// Return a new string with leading spaces removed, and trailing spaces truncated to one
  var truncatedSpaces: String {
    return self.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
      .replacingOccurrences(of: "\\s\\s+", with: " ", options: .regularExpression)
  }
  
  /// Form difference with the given string ignoring the case
  ///
  /// e.g.
  ///   - `"String".formDifference(with: "str")` should return `ing`
  ///   - `"String".formDifference(with: "")` should return `String`
  ///   - `"String".formDifference(with: "stx")` should return an empty string
  /// - parameter other: The second string that serves as the subtracted
  func formDifference(with other: String) -> String {
    let trimmedOther = other.truncatedSpaces
    guard !trimmedOther.isEmpty else { return self }
    let commonPrefix = self.commonPrefix(with: other, options: .caseInsensitive)
    guard commonPrefix.count == trimmedOther.count else { return "" }
    return String(self[commonPrefix.endIndex...])
  }
  
  func match(regex: NSRegularExpression) -> Substring? {
    guard
      let firstMatch = regex.firstMatch(in: self, options: .anchored, range: NSRange(location: 0, length: self.count))
      else { return nil }
    return self[Range(firstMatch.range, in: self)!]
  }
}
