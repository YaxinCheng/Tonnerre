//
//  TonnerreService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

protocol TonnerreService: Displayable {
  static var keyword: String { get }
  var argLowerBound: Int { get }
  var argUpperBound: Int { get }
  func prepare(input: [String]) -> [Displayable]
  func serve(source: Displayable, withCmd: Bool)
  
  var placeholder: String { get }
  
  init()
}
extension TonnerreService {
  var alterContent: String? { return nil }
  var alterIcon: NSImage? { return nil }
  var argUpperBound: Int { return argLowerBound }
  static var isDisabled: Bool {
    get {
      let userDeafult = UserDefaults.standard
      return userDeafult.bool(forKey: "\(Self.self)+Disabled")
    } set {
      let userDeafult = UserDefaults.standard
      userDeafult.set(newValue, forKey: "\(Self.self)+Disabled")
    }
  }
  var placeholder: String {
    return Self.keyword
  }
}

protocol TonnerreExtendService: class, TonnerreService, Codable {
  var keyword: String { get }
  var isDisabled: Bool { get set }
  var placeholder: String { get }
}

extension TonnerreExtendService {
  static var keyword: String { return "ExtendedService" }
  init() { fatalError("Load from JSON instead") }
  
  static var isDisabled: Bool {
    get { return false }
    set {}
  }
  
  var placeholder: String {
    return keyword
  }
  
  var isDisabled: Bool {
    get {
      let userDeafult = UserDefaults.standard
      return userDeafult.bool(forKey: "\(name)+\(keyword)+Disabled")
    } set {
      let userDeafult = UserDefaults.standard
      userDeafult.set(newValue, forKey: "\(name)+\(keyword)+Disabled")
    }
  }
}

protocol TonnerreInterpreterService: TonnerreService {
}
