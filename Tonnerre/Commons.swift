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
  case documentInxFinished
  case defaultInxFinished
  case AppleInterfaceStyle
  case designatedX
  case designatedY
  case defaultSearch
}

func getContext() -> NSManagedObjectContext {
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  return appDelegate.persistentContainer.viewContext
}

extension Array {
  func bipartite(standard: (Element)->Bool) -> ([Element], [Element]) {
    var first: [Element] = []
    var second: [Element] = []
    for element in self {
      if standard(element) { first.append(element) }
      else { second.append(element) }
    }
    return (first, second)
  }
}

extension NSImage { // Extensions for icons of built-in apps
  static var safari: NSImage {
    return NSImage(contentsOfFile: "/Applications/Safari.app/Contents/Resources/compass.icns") ?? #imageLiteral(resourceName: "tonnerre")
  }
  
  static var screenLock: NSImage {
    return NSImage(contentsOfFile: "/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane/Contents/Resources/DesktopScreenEffectsPref.icns") ?? #imageLiteral(resourceName: "tonnerre")
  }
  
  static var terminal: NSImage {
    return NSImage(contentsOfFile: "/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns") ?? #imageLiteral(resourceName: "tonnerre")
  }
  
  static var finder: NSImage {
    return NSImage(contentsOfFile: "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns") ?? #imageLiteral(resourceName: "tonnerre")
  }
  
  static var dictionary: NSImage {
    return NSImage(contentsOfFile: "/Applications/Dictionary.app/Contents/Resources/Dictionary.icns") ?? #imageLiteral(resourceName: "tonnerre")
  }
  
  static var calculator: NSImage {
    return NSImage(contentsOfFile: "/Applications/Calculator.app/Contents/Resources/AppIcon.icns") ?? #imageLiteral(resourceName: "tonnerre")
  }
}
