//
//  CBRecord+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import CoreData

extension CBRecord {
  static func recordInsert(value: String, type: String, limit: Int) {
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    let context = getContext()
    let count = (try? context.count(for: fetchRequest)) ?? 0
    if count >= limit { _ = removeOldest() }
    let newObject = CBRecord(context: context)
    newObject.type = type
    newObject.value = value
    newObject.time = Date()
    try? context.save()
  }
  
  private static func removeOldest() -> CBRecord? {
    let fetchRequest = NSFetchRequest<CBRecord>(entityName: "CBRecord")
    fetchRequest.fetchLimit = 1
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
    let context = getContext()
    guard let fetchedData = (try? context.fetch(fetchRequest))?.first else { return nil }
    context.delete(fetchedData)
    do {
      try context.save()
      return fetchedData
    } catch {
      return nil
    }
  }
}

extension CBRecord: Displayable {
  var name: String {
    if type! == "public.file-url" {
      return value!.components(separatedBy: "/").last ?? ""
    }
    return value ?? ""
  }
  
  var content: String {
    if type! == "public.file-url" {
      return URL(string: value!)?.path ?? value!
    } else {
      let dateFmt = DateFormatter()
      dateFmt.dateFormat = "HH:mm, MMM dd, YYYY"
      return "Copied at \(dateFmt.string(from: time!))"
    }
  }
  
  var icon: NSImage {
    if type! == "public.file-url" {
      let url = URL(string: value!)!
      return NSWorkspace.shared.icon(forFile: url.path)
    }
    return #imageLiteral(resourceName: "tonnerre")
  }
  
  
}
