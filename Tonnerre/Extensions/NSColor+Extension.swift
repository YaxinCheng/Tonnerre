//
//  NSColor+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-12.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

extension NSColor {
  convenience init(hexString: String) {
    let hex = hexString.trimmingCharacters(in: .init(charactersIn: "#"))
    guard
      hex.count == 6,
      let number = Int(hex, radix: 16)
    else { self.init(); return }
    let red = CGFloat((number >> 16) & 0xFF) / 255
    let green = CGFloat((number >> 8) & 0xFF) / 255
    let blue = CGFloat(number & 0xFF) / 255
    self.init(red: red, green: green, blue: blue, alpha: 1)
  }
}
