//
//  SettingService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-14.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct SettingService: BuiltInProvider {
  let defaultKeyword: String = "tonnerre"
  let name: String = "Tonnerre Settings"
  let content: String = "Open Tonnerre setting panels"
  let argLowerBound: Int = 0
  let argUpperBound: Int = 0
  let icon: NSImage = #imageLiteral(resourceName: "settings")
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    return [DisplayContainer<Int>(name: name, content: content, icon: icon, placeholder: defaultKeyword)]
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    let settingLocation = Bundle.main.bundleURL.appendingPathComponent("/Contents/Applications/SettingPanel.app")
    let workspace = NSWorkspace.shared
    _ = try? workspace.launchApplication(at: settingLocation, options: .default, configuration: [:])
  }
}
