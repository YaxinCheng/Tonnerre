//
//  EnvResource.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

/// Arguments executed to make the environment
protocol EnvResource {
  init()
  /// Export this resource to the given environment
  /// - parameter env: the environment the resource will be added to
  func export(to env: Environment)
}
