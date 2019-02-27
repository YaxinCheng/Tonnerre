//
//  Environment.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct Environment {
  private let services: [EnvArg]
  
  init() {
    services = [CacheArg(), SupportFoldersArg(),
                DefaultSettingArg(), HelperArg(),
                ProviderMapArg(), ClipboardArg()]
  }
  
  func setup() {
    services.forEach { $0.setup() }
  }
}
