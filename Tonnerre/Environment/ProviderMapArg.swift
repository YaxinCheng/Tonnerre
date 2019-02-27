//
//  ProviderMapArg.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct ProviderMapArg: EnvArg {
  func setup() {
    ProviderMap.shared.start()
  }
  
  func tearDown() {
    ProviderMap.shared.stop()
  }
}
