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
}

enum CoreDataEntities: String {
  case IndexingDir
  case FailedPath
  case AvailableMode
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
