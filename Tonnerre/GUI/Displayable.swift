//
//  Displayable.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol Displayable {
  var icon: NSImage { get }
  var name: String { get }
  var content: String { get }
  var alterContent: String? { get }
  var alterIcon: NSImage? { get }
  var itemIdentifier: NSUserInterfaceItemIdentifier { get }
  var placeholder: String { get }
}

extension Displayable {
  var name: String { return "\(Self.self)" }
  var content: String { return "" }
  var alterContent: String? { return nil }
  var alterIcon: NSImage? { return nil }
  var itemIdentifier: NSUserInterfaceItemIdentifier { return .ServiceCell }
}
