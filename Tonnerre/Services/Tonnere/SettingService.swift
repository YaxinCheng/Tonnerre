//
//  SettingService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-14.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct SettingService: TonnerreService {
  static let keyword: String = "tonnerre"
  let name: String = "Tonnerre Settings"
  let content: String = "Open Tonnerre setting panels"
  let argLowerBound: Int = 0
  let argUpperBound: Int = 1
  let icon: NSImage = #imageLiteral(resourceName: "settings")
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    return [self]
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    DispatchQueue(label: "SettingPanelSetup").async {
      let settingLocation = Bundle.main.bundleURL.appendingPathComponent("/Contents/Applications/SettingPanel.app")
      let workspace = NSWorkspace.shared
      _ = try? workspace.launchApplication(at: settingLocation, options: .default, configuration: [:])
    }
  }
}
