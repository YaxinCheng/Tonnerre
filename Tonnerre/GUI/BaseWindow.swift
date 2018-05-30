//
//  BaseWindow.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class BaseWindow: NSWindow {
  override var canBecomeKey: Bool {
    return true
  }
  
  override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
    super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    
    isMovableByWindowBackground = true
    isMovable = true
    folderChecks()
  }
  
  private func folderChecks() {
    let fileManager = FileManager.default
    guard
      let appSupportPath = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
      let bundleID = Bundle.main.bundleIdentifier
      else { return }
    let dataFolderPath = appSupportPath.appendingPathComponent(bundleID)
    let indexFolder = dataFolderPath.appendingPathComponent("Indices")
    
    if !fileManager.fileExists(atPath: indexFolder.path) {
      let userDefault = UserDefaults.standard
      userDefault.set(dataFolderPath, forKey: StoredKeys.appSupportDir.rawValue)
      do {
        try fileManager.createDirectory(at: indexFolder, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("Cannot create the app support folder")
      }
    }
  }
  
  private func deleteData() {
    let deleteRequest = NSFetchRequest<IndexingDir>(entityName: "IndexingDir")
    deleteRequest.includesPropertyValues = false
    var counter = 0
    let context = getContext()
    for each in ((try? context.fetch(deleteRequest)) ?? []) {
      print(each.path)
      context.delete(each)
      counter += 1
    }
    print("Delete IndexingDir: \(counter)")
    let failedRequest = NSFetchRequest<FailedPath>(entityName: "FailedPath")
    failedRequest.includesPropertyValues = false
    counter = 0
    for each in ((try? context.fetch(failedRequest)) ?? []) {
      print(each.path)
      context.delete(each)
      counter += 1
    }
    print("Delete FailedPath: \(counter)")
    
    try? context.save()
    UserDefaults.standard.set(false, forKey: StoredKeys.documentInxFinished.rawValue)
    UserDefaults.standard.set(false, forKey: StoredKeys.defaultInxFinished.rawValue)
    //    exit(0)
  }

}
