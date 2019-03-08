//
//  ProviderMapResource.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct ProviderMapResource: EnvResource {
  func export(to env: Environment) {
    ProviderMap.shared.start()
  }
}
