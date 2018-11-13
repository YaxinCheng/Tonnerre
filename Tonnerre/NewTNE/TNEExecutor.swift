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
  func prepare(withInput input: [String], provider: TNEServiceProvider) -> [DisplayProtocol]
  func execute(withArguments args: Arguments) throws -> JSON?
}

extension TNEExecutor {
  func prepare(withInput input: [String], provider: TNEServiceProvider) -> [DisplayProtocol] {
    if provider.argLowerBound == provider.argUpperBound &&
      provider.argUpperBound == 0 {
      return [DisplayableContainer<Any>(name: provider.name,
                                        content: provider.content,
                                        icon: provider.icon,
                                        placeholder: provider.keyword)
            ]
    } else {
      return [DisplayableContainer<Any>(name: provider.name.filled(arguments: input)
        , content: provider.content.filled(arguments: input), icon: provider.icon,
          placeholder: provider.keyword)]
    }
  }
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
  case supply(input: [String])
  case serve(choice: [String: Any])
  
  var argumentType: String {
    switch self {
    case .supply(input: _): return "--supply"
    case .serve(choice: _): return "--serve"
    }
  }
}
