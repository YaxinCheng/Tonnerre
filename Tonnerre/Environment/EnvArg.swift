//
//  EnvArg.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

/// Arguments executed to make the environment
protocol EnvArg {
  /// Set up the environment for this parameter
  func setup()
  /// Remove the function from the environment
  func tearDown()
}

extension EnvArg {
  func tearDown() {}
}
