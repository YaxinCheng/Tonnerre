//
//  TonnerreFieldDelegate.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol TonnerreFieldDelegate: class {
  /// When text value in textField is changed, notify the delegate about the change
  /// - parameter value: the value after changing
  func textDidChange(value: String)
  /// When enter key is pressed, notify the delegate one service is selected
  func serviceDidSelect()
}
