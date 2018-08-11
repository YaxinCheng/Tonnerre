//
//  ViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {

  @IBOutlet weak var statusBarView: NSView!
  @IBOutlet weak var contentView: NSView!
  @IBOutlet weak var tabBarView: NSStackView!
  private var currentTab: NSStoryboardSegue.Identifier = .secondTab
  private static let settingOptions: [String: Any] = {
    guard
      let settingFile = Bundle.main.path(forResource: "Settings", ofType: "plist"),
      let settingData = NSDictionary(contentsOfFile: settingFile) as? [String: Any]
    else {
      fatalError("Cannot find settings file")
    }
    return settingData
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    statusBarView.layer?.backgroundColor = .white
    contentView.layer?.backgroundColor = .clear
    performSegue(withIdentifier: .firstTab, sender: self)
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    view.window?.title = ""
  }

  override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
    guard identifier != currentTab else { return false }
    currentTab = identifier
    return true
  }
  
  typealias SettingOption = (title: String, detail: String, type: SettingCellType, settingKey: String)
  
  private func loadSettings(with identifier: NSStoryboardSegue.Identifier) -> (left: [SettingOption], right: [SettingOption]) {
    guard
      let tabData = ViewController.settingOptions[identifier.rawValue] as? [String: [[String: String]]]
    else { return ([], []) }
    let constructOption: ([String: String]) -> SettingOption = {
      ($0["title"]!, $0["detail"]!, SettingCellType(rawValue: $0["type"]!)!, $0["settingKey"] ?? "")
    }
    let leftOptions = tabData["left"]!.map(constructOption)
    let rightOptions = tabData["right"]!.map(constructOption)
    return (leftOptions, rightOptions)
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    guard
      let identifier = segue.identifier,
      let destinationVC = segue.destinationController as? SettingViewController
    else { return }
    destinationVC.settingOptions = loadSettings(with: identifier)
  }
}

