//
//  EnvService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol EnvService {
  func setup()
  func tearDown()
}

extension EnvService {
  func tearDown() {}
}
