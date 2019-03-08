//
//  HelperResource.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct HelperResource: EnvResource {
  func export(to env: Environment) {
    #if RELEASE
    TonnerreHelper.launch()
    #endif
  }
}
