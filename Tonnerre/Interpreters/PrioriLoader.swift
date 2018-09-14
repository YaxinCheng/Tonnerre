//
//  PrioriLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct PrioriLoader: LoaderProtocol {
  typealias DataType = TonnerreService
  private let providers: [TonnerreService]
  
  func find(keyword: String) -> [TonnerreService] {
    return providers
  }
  
  init() {
    providers  = [LaunchService(), CalculationService(), URLService(), CurrencyService()]
    let saveToSettings: ([TonnerreService]) -> () = { providers in
      DispatchQueue.global(qos: .background).async {
        let userDefault = UserDefaults.shared
        let settings = providers[1...].map { [$0.name, $0.content, type(of: $0).settingKey] }
        userDefault.set(settings, forKey: .prioriProviders)
      }
    }
    saveToSettings(providers)
  }
}
