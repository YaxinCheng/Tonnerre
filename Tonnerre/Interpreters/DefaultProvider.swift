//
//  DefaultProvider.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-12-09.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum DefaultProvider {
  static var id: String? {
    set {
      TonnerreSettings.set(newValue ?? "", forKey: .defaultProvider)
    } get {
      return TonnerreSettings.get(fromKey: .defaultProvider) as? String
    }
  }
}
