//
//  GradientColours.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-12.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct GradientColours {
  typealias Gradient = (begin: NSColor, end: NSColor)
  
  private let enabledColours: [(String, String)] = [
    ("#a18cd1", "#fbc2eb"),
    ("#ff9a9e", "#fad0c4"),
    ("#ffecd2", "#fcb69f"),
    ("#f6d365", "#fda085"),
    ("#a1c4fd", "#c2e9fb"),
    ("#84fab0", "#8fd3f4"),
    ("#e0c3fc", "#8ec5fc"),
    ("#4facfe", "#00f2fe"),
    ("#43e97b", "#38f9d7"),
    ("#fa709a", "#fee140"),
    ("#5ee7df", "#b490ca"),
    ("#2af598", "#009efd"),
    ("#ebbba7", "#cfc7f8"),
    ("#74ebd5", "#9face6"),
    ("#ff0844", "#ffb199"),
    ("#ff758c", "#ff7eb3"),
    ("#b721ff", "#21d4fd"),
    ("#96deda", "#50c9c3")
  ]

  static let disabled: Gradient = {
    return (NSColor(hexString: "#f5f7fa"), NSColor(hexString: "#c3cfe2"))
  }()
  
  func generate() -> Gradient {
    let rand = Int(arc4random_uniform(UInt32(enabledColours.count)))
    let colour = enabledColours[rand]
    return (NSColor(hexString: colour.0), NSColor(hexString: colour.1))
  }
}
