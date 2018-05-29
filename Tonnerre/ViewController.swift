//
//  ViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  let indexManager = CoreIndexing()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    folderChecks()
  }
  
  override func viewDidAppear() {
    indexManager.check()
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
  }


}

