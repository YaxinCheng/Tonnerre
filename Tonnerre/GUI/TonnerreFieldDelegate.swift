//
//  TonnerreFieldDelegate.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol TonnerreFieldDelegate: class {
  func textDidChange(value: String)
  func serviceDidSelect()
}
