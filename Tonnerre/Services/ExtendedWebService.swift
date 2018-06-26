//
//  ExtendedWebService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

@objc protocol ExtendedWebService {
  // TonnerreService
  init()
  var storedImage: NSImage? { get set }
}

extension ExtendedWebService {
  var alterContent: String? { return nil }
  var alterIcon: NSImage? { return nil }
  var icon: NSImage? {
    return storedImage ?? #imageLiteral(resourceName: "safari")
  }
  static var isDisabled: Bool {
    get {
      let userDeafult = UserDefaults.standard
      return userDeafult.bool(forKey: "\(Self.self)+Disabled")
    } set {
      let userDeafult = UserDefaults.standard
      userDeafult.set(newValue, forKey: "\(Self.self)+Disabled")
    }
  }
  
  var itemIdentifier: NSUserInterfaceItemIdentifier { return .ServiceCell }
}
