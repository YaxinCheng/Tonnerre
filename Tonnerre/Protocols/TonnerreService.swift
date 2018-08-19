//
//  TonnerreService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

/**
 The base protocol that each service provider in the system should conforms to
 
 Each service provider should provide services based on user inputs
*/
protocol TonnerreService: DisplayProtocol {
  /**
   The specific word used to locate the service
  */
  static var keyword: String { get }
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
   - parameter input: the user input excluding the keyword
   - returns: an array of displayable items each represent a specific service
  */
  func prepare(input: [String]) -> [DisplayProtocol]
  /**
   The function that serves the user with the service it selected
   - parameter source: the user selected service
   - parameter withCmd: a flag indicates whether the user selected the service with cmd key modifier
  */
  func serve(source: DisplayProtocol, withCmd: Bool)
  
  /**
   Constructor.
   - Note: no parameter should be given for TonnerreService constructors
  */
  init()
}
extension TonnerreService {
  var alterContent: String? { return nil }
  var alterIcon: NSImage? { return nil }
  var argUpperBound: Int { return argLowerBound }
  static var settingKey: String { return "\(Self.self)+Disabled" }
  /**
   A bool value specifies if the service is disabled. Disabled services cannot be called
  */
  static var isDisabled: Bool {
    get {
      let userDeafult = UserDefaults.shared
      return userDeafult.bool(forKey: settingKey)
    } set {
      let userDeafult = UserDefaults.shared
      userDeafult.set(newValue, forKey: settingKey)
    }
  }
  var placeholder: String {
    return Self.keyword
  }
}

protocol TonnerreInstantService {}
