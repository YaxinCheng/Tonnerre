//
//  StoredKeys.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

enum StoredKeys: String {// Keys used in UserDefault
  case appSupportDir
  case designatedX
  case designatedY
  case defaultSearch
}

func getContext() -> NSManagedObjectContext {
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  return appDelegate.persistentContainer.viewContext
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
