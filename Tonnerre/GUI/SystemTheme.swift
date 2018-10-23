//
//  SystemTheme.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

enum SystemTheme {
  case light
  case dark

  static var current: SystemTheme {
    return UserDefaults.standard.value(forKey: "AppleInterfaceStyle") == nil ? .light : .dark
  }
}
