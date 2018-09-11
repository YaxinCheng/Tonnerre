//
//  Commons.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

enum StoredKey: String {// Keys used in UserDefault
  case appSupportDir
  case designatedX
  case designatedY
  case defaultSearch
  case defaultSettingsSet = "tonnerre.builtin"
  /**
   This is true when built-in services are not set for settings
  */
  case builtinServiceSet
}

func getContext() -> NSManagedObjectContext {
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  return appDelegate.persistentContainer.viewContext
}
