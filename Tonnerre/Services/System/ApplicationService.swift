//
//  ApplicationService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ApplicationService: BuiltInProvider {
  let name: String = "Quit Programs"
  let content: String = "Find and quite running programs"
  let alterContent: String? = "Force quit program"
  let defaultKeyword: String = "quit"
  let icon: NSImage = #imageLiteral(resourceName: "close")
  let argUpperBound: Int = .max
  let argLowerBound: Int = 0
  let defered: Bool = true
  
  func serve(service: DisplayItem, withCmd: Bool) {
    guard let value = (service as? DisplayContainer<NSRunningApplication>)?.innerItem else { return }
    if withCmd { value.forceTerminate() }
    else { value.terminate() }
  }

  func prepare(withInput input: [String]) -> [DisplayItem] {
    let workspace = NSWorkspace.shared
    let runningApps = workspace.runningApplications.filter { $0.activationPolicy == .regular }
    if input.isEmpty || (input.first?.isEmpty ?? false) {
      return runningApps.map { DisplayContainer(name: "Quit \($0.localizedName!)", content: $0.bundleURL!.path, icon: $0.icon!, innerItem: $0, placeholder: $0.localizedName!) }
    } else {
      let filteredApps = runningApps.filter { match(appName: $0.localizedName!, query: input) }
      return filteredApps.map { DisplayContainer(name: "Quit \($0.localizedName!)", content: $0.bundleURL!.path, icon: $0.icon!, innerItem: $0, placeholder: $0.localizedName!) }
    }
  }
  
  private func match(appName: String, query: [String]) -> Bool {
    guard query.count > 0 else { return true }
    let initials = String(appName.lowercased().components(separatedBy: " ").compactMap { $0.first })
    if initials == query.first!.lowercased() { return true }
    let matchPatternString = ".*?\\s*?" + query.joined(separator: ".*?\\s*?") + "\\s*?.*?"
    let pattern = try! NSRegularExpression(pattern: matchPatternString, options: .caseInsensitive)
    return appName.match(regex: pattern) != nil
  }
}

