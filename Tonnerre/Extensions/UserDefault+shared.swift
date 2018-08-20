//
//  UserDefault+shared.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension UserDefaults {
  static var shared: UserDefaults {
    return UserDefaults(suiteName: "Tonnerre")!
  }
}
