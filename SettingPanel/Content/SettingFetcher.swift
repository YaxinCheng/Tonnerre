//
//  SettingFetcher.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol SettingFetcher {
  func fetch() -> [SettingItem]
}

struct BuiltinProviderFetcher: SettingFetcher {
  func fetch() -> [SettingItem] {
    let loader = BuiltinProviderLoader()
    return loader.providers.map { ProviderItem(id: $0.0, keyword: $0.1, name: $0.2, content: $0.3) }
  }
}

struct TNEProviderFetcher: SettingFetcher {
  func fetch() -> [SettingItem] {
    let loader = TNEProviderLoader()
    return loader.providers.map { ProviderItem(id: $0.0, keyword: $0.1, name: $0.2, content: $0.3) }
  }
}

struct GeneralSettingFetcher: SettingFetcher {
  func fetch() -> [SettingItem] {
    let loader = GeneralSettingLoader()
    return loader.settings.map { TextItem(id: $0.0, name: $0.1, content: $0.2) }
  }
}
