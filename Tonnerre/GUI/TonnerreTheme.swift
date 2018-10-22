//
//  TonnerreTheme.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol ThemeProtocol {
  var theme: TonnerreTheme { get set }
}

enum TonnerreTheme {
  case light
  case dark
  
  var placeholderColour: NSColor {
    switch self {
    case .dark: return NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.5)
    case .light: return NSColor(calibratedRed: 61/255, green: 61/255, blue: 61/255, alpha: 0.4)
    }
  }
  
  var imgColour: NSColor {
    switch self {
    case .dark: return .white
    case .light: return .black
    }
  }

  static var current: TonnerreTheme {
    let followsSystem = UserDefaults.shared[.themeFollowsSystem] as? Bool ?? true
    let systemIsLight = UserDefaults.standard.value(forKey: "AppleInterfaceStyle") == nil
    return systemIsLight && followsSystem ? .light : .dark
  }
}
