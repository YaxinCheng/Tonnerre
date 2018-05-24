//
//  ViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  let searchManager = SearchService()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear() {
    folderChecks()
    searchManager.check()
  }
  
  override func viewDidDisappear() {
    
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
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
    let fetchRequest = NSFetchRequest<AvailableMode>(entityName: CoreDataEntities.AvailableMode.rawValue)
    let context = getContext()
    do {
      let count = try context.count(for: fetchRequest)
      if count == 0 {
        let modes = (0..<3).map({_ in
          AvailableMode(context: context)
        })
        zip(modes, ["defaultMode", "name", "content"]).forEach { (mode, name) in
          mode.name = name
        }
        try context.save()
      }
    } catch {
      print(error)
    }
  }


}

