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
  
  var highlightColour: NSColor {
    switch self {
    case .dark: return NSColor(calibratedRed: 20/255, green: 168/255, blue: 1, alpha: 0.8)
    case .light: return NSColor(calibratedRed: 73/255, green: 109/255, blue: 216/255, alpha: 0.8)
    }
  }
  
  static var currentTheme: TonnerreTheme {
    return UserDefaults.standard.value(forKey: StoredKeys.AppleInterfaceStyle.rawValue) != nil ? .dark : .light
  }
}
