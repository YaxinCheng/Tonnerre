//
//  HelperArg.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation
import os

class HelperArg: EnvArg {
  func setup() {
    #if RELEASE
    TonnerreHelper.launch()
    #endif
  }
}
