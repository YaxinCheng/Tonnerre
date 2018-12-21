//
//  TNEExecutor.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/// Errors may be thrown from TNE Executor
enum ExecuteError: Error {
  /// This type of script is not supported by TNE Executor yet
  case unsupportedScriptType
  /// This script execution is stopped by a runtime error in the script
  ///
  /// **reason** parameter is a string of the error message
  case runtimeError(reason: String)
  /// For certain TNE Script, the input is constraint to a certain format
  /// , if not fulfiled, this error will be threw
  ///
  /// **information** parameter is a string of the correct format
  case wrongInputFormatError(information: String)
}

/// All TNE Script should be executed through its TNE Executor
protocol TNEExecutor {
  typealias Arguments = TNEArguments
  typealias Error = ExecuteError
  /// Build the executor based on the script file path
  /// - parameter scriptPath: The path to the script.
  /// - note: Constructor will fail if the script path doesn't contain a
  ///   main script, or the main script's type does not match with the
  ///   executor
  init?(scriptPath: URL)
  /// Build one services with given input
  /// - parameter input: The user input query passed to the TNE Script
  /// - parameter provider: The TNE Script which is called
  /// - returns: a placeholder service based on the input and provider
  func prepare(withInput input: [String], provider: TNEServiceProvider) -> DisplayProtocol
  /// Execute the TNE Script and return the result as a JSON
  /// - parameter args: The type of execution and the input from user
  /// - returns: An array-styled JSON returned from the TNE running result.
  ///   The result can be nil, if there is no result
  /// - throws: TNEExecutor.Error.runtimeError
  func execute(withArguments args: Arguments) throws -> JSON?
}

extension TNEExecutor {
  func prepare(withInput input: [String], provider: TNEServiceProvider) -> DisplayProtocol {
    if provider.argLowerBound == provider.argUpperBound &&
      provider.argUpperBound == 0 {
      return DisplayableContainer<Any>(name: provider.name,
                                        content: provider.content,
                                        icon: provider.icon,
                                        placeholder: provider.keyword)
      
    } else {
      return DisplayableContainer<Any>(name: provider.name.filled(arguments: input)
        , content: provider.content.filled(arguments: input), icon: provider.icon,
          placeholder: provider.keyword)
    }
  }
}

/// The arguments used to execute the TNEScript
enum TNEArguments {
  /// Execute the TNE Script in `supply` mode.
  /// `supply` mode matches with the ServiceProvider.supply, which loads
  /// services asynchronizingly
  ///
  /// **input** parameter is the user input query.
  ///
  /// Execution of `supply` mode generally returns a list of services
  case supply(input: [String])
  /// Execute the TNE Script in `serve` mode.
  /// `serve` mode matches with the ServiceProvider.serve, which calls the
  /// script to complete and react to the user selected service
  ///
  /// **choice** parameter is a dictionary containing the key information
  /// of the user selected service.
  ///
  /// Execution of `serve` mode generally returns nothing
  case serve(choice: [String: Any])
  
  /// Argument in bash when executing
  var argumentType: String {
    switch self {
    case .supply(input: _): return "--supply"
    case .serve(choice: _): return "--serve"
    }
  }
}
