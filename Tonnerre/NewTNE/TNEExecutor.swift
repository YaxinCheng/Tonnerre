//
//  TNEExecutor.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum ExecuteError: Error {
  case unsupportedScriptType
  case runtimeError(reason: String)
  case wrongInputFormatError
  case missingAttribute(_ attribute: String, atPath: URL)
}

protocol TNEExecutor {
  typealias Arguments = TNEArguments
  typealias Error = ExecuteError
  init?(scriptPath: URL)
  func execute(withArguments args: Arguments) throws -> JSON?
}

func createExecutor(basedOn scriptPath: URL) throws -> TNEExecutor {
  let executor: TNEExecutor? =
    PyExecutor(scriptPath: scriptPath) ??
    ASExecutor(scriptPath: scriptPath) ??
    JSONExecutor(scriptPath: scriptPath)
  guard executor != nil else {
    throw TNEExecutor.Error.unsupportedScriptType
  }
  return executor!
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
