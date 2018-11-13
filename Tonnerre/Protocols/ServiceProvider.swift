//
//  ServiceProvider.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 The base protocol that each service provider in the system should conforms to
 
 Each service provider should provide services based on user inputs
 */
protocol ServiceProvider: DisplayProtocol {
  ///
  /// a single unique id
  ///
  var id: String { get }
  /**
   The specific word used to locate the service
   */
  var keyword: String { get }
  /**
   Except the keyword, the number of extra words needed to call `prepare` function
   */
  var argLowerBound: Int { get }
  /**
   Except the keyword, the number of extra words the `prepare` function can take
   */
  var argUpperBound: Int { get }
  /**
   The function that accepts the user input, and give certain services based on the input
   - Note: This function runs synchronizingly, so it should only gives out some at once services.
   For more complicated services should be provided by the `loadService(withInput:)`
   - parameter input: the user input excluding the keyword
   - returns: an array of displayable items each represent a specific service
   */
  func prepare(withInput input: [String]) -> [DisplayProtocol]
  /**
   The function that load services asynchronizingly. All the heavy loading work should be put here
   - parameter input: the user input excluding the keyword
   - returns: an array of displayable items each represent a specific service
   */
  func supply(withInput input: [String]) -> [DisplayProtocol]
  /**
   The function that serves the user with the service it selected
   - parameter source: the user selected service
   - parameter withCmd: a flag indicates whether the user selected the service with cmd key modifier
   */
  func serve(service: DisplayProtocol, withCmd: Bool)
  ///
  /// This flag marks a provider will only be shown when keywords match exactly
  ///
  /// Generally, when a keyword like `g` would trigger `google` service.
  /// But when a provider is marked as defered, it will not be shown until
  /// the keyword matches exactly
  var defered: Bool { get }
}

extension ServiceProvider {
  var defered: Bool { return false }
  func supply(withInput input: [String]) -> [DisplayProtocol] {
    return []
  }
}
