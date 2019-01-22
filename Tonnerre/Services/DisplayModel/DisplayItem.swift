//
//  Displayable.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

/**
 Base protocol for any item that needs to be displayed in the collectionView
*/
protocol DisplayItem {
  /**
   The icon shown on the left side of the displayable item
  */
  var icon: NSImage { get }
  /**
   The name shown on the serviceLabel
  */
  var name: String { get }
  /**
   The content shown on the introLabel
  */
  var content: String { get }
  /**
   The alternative content shown on the introLabel when cmd is on holding
  */
  var alterContent: String? { get }
  /**
   The alternative icon shown on the left side when cmd is on holding
  */
  var alterIcon: NSImage? { get }
  /**
   The placeholder content when for this item shown on the textField
  */
  var placeholder: String { get }
}

extension DisplayItem {
  var name: String { return "\(Self.self)" }
  var content: String { return "" }
  var alterContent: String? { return nil }
  var alterIcon: NSImage? { return nil }
}
