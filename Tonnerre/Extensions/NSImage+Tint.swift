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

extension NSImage { // Extensions for icons of built-in apps
  static var safari: NSImage {
    return NSImage(contentsOfFile: "/Applications/Safari.app/Contents/Resources/compass.icns") ?? #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  static var screenLock: NSImage {
    return NSImage(contentsOfFile: "/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane/Contents/Resources/DesktopScreenEffectsPref.icns") ?? #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  static var terminal: NSImage {
    return NSImage(contentsOfFile: "/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns") ?? #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  static var finder: NSImage {
    return NSImage(contentsOfFile: "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns") ?? #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  static var dictionary: NSImage {
    return NSImage(contentsOfFile: "/Applications/Dictionary.app/Contents/Resources/Dictionary.icns") ?? #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  static var calculator: NSImage {
    return NSImage(contentsOfFile: "/Applications/Calculator.app/Contents/Resources/AppIcon.icns") ?? #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
  }
}
