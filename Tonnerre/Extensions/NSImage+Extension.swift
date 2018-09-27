//
//  NSImage+Tint.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension NSImage {
  static var safari: NSImage {
    return NSImage(contentsOfFile: "/Applications/Safari.app/Contents/Resources/compass.icns") ?? #imageLiteral(resourceName: "notFound").tintedImage(with: TonnerreTheme.current.imgColour)
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
