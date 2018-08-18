//
//  Common.swift
//  TonnerreIndexHelper
//
//  Created by Yaxin Cheng on 2018-06-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

func getContext() -> NSManagedObjectContext {
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  return appDelegate.persistentContainer.viewContext
}

enum StoredKeys: String {// Keys used in UserDefault
  case appSupportDir
  case documentInxFinished
  case defaultInxFinished
  case designatedX
  case designatedY
}
