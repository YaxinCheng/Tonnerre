//
//  TNEExecutor.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum ExecuteError: Error {
  case runtimeError(reason: String)
}

protocol TNEExecutor {
  typealias Arguments = TNEArguments
  typealias Error = ExecuteError
  init?(scriptPath: URL)
  func execute(withArguments args: Arguments) throws -> JSON?
  func terminate()
}

extension TNEExecutor {
  static var validExtensions: Set<String> {
    return ["py", "json", "scpt"]
  }
}

enum TNEArguments {
  case prepare(input: [String])
  case serve(choice: [String: Any])
  
  var argumentType: String {
    switch self {
    case .prepare(input: _): return "--prepare"
    case .serve(choice: _): return "--serve"
    }
  }
}
