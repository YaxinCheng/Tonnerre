//
//  ProviderFetcher.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol ProviderFetcher {
  func fetch() -> [SettingItem]
}

struct BuiltinProviderFetcher: ProviderFetcher {
  func fetch() -> [SettingItem] {
    let info = BuiltinProviderInfo()
    return info.info.map { ProviderItem(id: $0.0, keyword: $0.1, name: $0.2, content: $0.3) }
  }
}
