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
  
  private var highlightedButton: NSButton?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    statusBarView.layer?.backgroundColor = .white
    tabBarView.layer?.backgroundColor = .clear
    contentView.layer?.backgroundColor = .clear
    
    for button in tabBarView.subviews where button is NSButton {
      NSLayoutConstraint.activate([
        button.heightAnchor.constraint(equalToConstant: 36)
      ])
      (button as! NSButton).image = (button as! NSButton).image?.tintedImage(with: .gray)
    }
    highlightedButton = tabBarView.subviews[0] as? NSButton
    performSegue(withIdentifier: .firstTab, sender: highlightedButton)
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    view.window?.title = ""
  }
  
  override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
    guard identifier != currentTab else { return false }
    currentTab = identifier
    highlightedButton?.image = highlightedButton?.image?.tintedImage(with: .lightGray)
    highlightedButton = sender as? NSButton
    highlightedButton?.image = highlightedButton?.image?.tintedImage(with: .white)
    return true
  }
  
  typealias SettingOption = (title: String, detail: String, type: SettingCellType, settingKey: String)
  
  private func loadSettings(with identifier: NSStoryboardSegue.Identifier) -> (left: [SettingOption], right: [SettingOption]) {
    if identifier == .firstTab {
      guard
        let settingsFile = Bundle.main.url(forResource: "Settings", withExtension: "plist"),
      let settings = NSDictionary(contentsOf: settingsFile) as? [String: [String: [String: String]]]
      else { return ([], []) }
      let extract: ((key: String, value: [String: String]))->SettingOption = {
        ($0.value["title"]!, $0.value["detail"]!, SettingCellType(rawValue: $0.value["type"]!)!, $0.key)
      }
      let leftData = settings["left"]?.map(extract) ?? []
      let rightData = settings["right"]?.map(extract) ?? []
      return (leftData, rightData)
    } else if identifier == .secondTab {
      let userDefault = UserDefaults.shared
      let builtinServices = userDefault.array(forKey: "tonnerre.builtin") as? [[String]] ?? []
      let leftData: [SettingOption] = builtinServices.map { ($0[0], $0[1], .gradient, $0[2]) }
      let rightData = readInTNEs() + readInWebex()
      return (leftData, rightData)
    } else { return ([], []) }
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    guard
      let identifier = segue.identifier,
      let destinationVC = segue.destinationController as? SettingViewController
    else { return }
    destinationVC.settingOptions = loadSettings(with: identifier)
  }
  
  private func readInTNEs() -> [SettingOption] {
    do {
      let path = UserDefaults.shared.url(forKey: "appSupportDir")!.appendingPathComponent("Services")
      let contents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
      var options: [SettingOption] = []
      for fileURL in contents where fileURL.pathExtension == "tne" {
        let jsonPath = fileURL.appendingPathComponent("description.json")
        let jsonData = try Data(contentsOf: jsonPath)
        guard
          let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? [String: String],
          let name = jsonObject["name"],
          let content = jsonObject["content"]
        else { continue }
        options.append((name, content, .gradient, "\(fileURL)+isDisabled"))
      }
      return options
    } catch {
      #if DEBUG
      print("setting error with tne loading", error)
      #endif
      return []
    }
  }
  
  private func readInWebex() -> [SettingOption] {
    let path = UserDefaults.shared.url(forKey: "appSupportDir")!.appendingPathComponent("Services/web.json")
    do {
      let jsonData = try Data(contentsOf: path)
      guard
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
        as? Dictionary<String, [String: Any]>
      else { return [] }
      var options: [SettingOption] = []
      for (attrName, objectContent) in jsonObject {
        guard
          let name = objectContent["name"] as? String,
          let detail = objectContent["content"] as? String
        else { continue }
        options.append((name, detail, .gradient, "\(attrName)+isDisabled"))
      }
      return options
    } catch {
      #if DEBUG
      print("setting error with webex loading", error)
      #endif
      return []
    }
    return []
  }
}

