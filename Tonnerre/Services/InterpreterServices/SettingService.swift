//
//  SettingService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-14.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct SettingService: TonnerreService {
  static let keyword: String = "tonnerre"
  let name: String = "Tonnerre Settings"
  let content: String = "Open Tonnerre setting panels"
  let argLowerBound: Int = 0
  let argUpperBound: Int = 1
  var icon: NSImage {
    return #imageLiteral(resourceName: "settings").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    return [self]
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    DispatchQueue(label: "SettingPanelSetup").async {
      self.makeSettingOptions()
      let settingLocation = Bundle.main.bundleURL.appendingPathComponent("/Contents/Applications/SettingPanel.app")
      let workspace = NSWorkspace.shared
      _ = try? workspace.launchApplication(at: settingLocation, options: .default, configuration: [:])
    }
  }
  
  private func makeSettingOptions() {
    let userDefault = UserDefaults.shared
    guard var settings = userDefault.dictionary(forKey: .defaultSettingsSet) as? SettingDict,
      !settings.isEmpty else { fatalError("Setting dict cannot be retrieved") }
    settings["secondTab"]!["right"] = [:]
    let allExtensions = TonnerreInterpreter.loader.extensionServices
      .compactMap { ($0 as? DynamicProtocol)?.serviceTrie.find(value: "") }
      .reduce([], +)
    for `extension` in allExtensions {
      let key = "\(`extension`.extraContent ?? "")_\(`extension`.name)_\(`extension`.content)+isDisabled"
      settings["secondTab"]!["right"]![key] = ["title": `extension`.name, "detail": `extension`.content, "type": "gradient"]
    }
    userDefault.set(settings, forKey: .defaultSettingsSet)
  }
}
