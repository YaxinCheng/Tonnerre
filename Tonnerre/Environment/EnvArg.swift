//
//  EnvArg.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol EnvArg {
  func setup()
  func tearDown()
}

extension EnvArg {
  func tearDown() {}
}
