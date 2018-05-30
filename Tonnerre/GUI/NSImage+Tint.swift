//
//  NSImage+Tint.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

extension NSImage {
  func tintedImage(with colour: NSColor) -> NSImage {
    guard let tinted = self.copy() as? NSImage else { return self }
    tinted.lockFocus()
    colour.set()
    let imageRect = NSRect(origin: NSZeroPoint, size: size)
    NSRect.fill(imageRect)(using: .sourceAtop)
    tinted.unlockFocus()
    return tinted
  }
}
