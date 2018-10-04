//
//  ApplicationService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct ApplicationService: TonnerreService {
  let name: String = "Quit program"
  let content: String = "Find and quite a running program"
  let alterContent: String? = "Force quit program"
  static let keyword: String = "quit"
  var icon: NSImage {
    return #imageLiteral(resourceName: "close").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  let argUpperBound: Int = Int.max
  let argLowerBound: Int = 0
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let value = (source as? DisplayableContainer<NSRunningApplication>)?.innerItem else { return }
    if withCmd { value.forceTerminate() }
    else { value.terminate() }
  }

  func prepare(input: [String]) -> [DisplayProtocol] {
    let workspace = NSWorkspace.shared
    let runningApps = workspace.runningApplications.filter { $0.activationPolicy == .regular }
    if input.isEmpty || (input.first?.isEmpty ?? false) {
      return runningApps.map { DisplayableContainer(name: $0.localizedName!, content: $0.bundleURL!.path, icon: $0.icon!, priority: priority, innerItem: $0) }
    } else {
      let filteredApps = runningApps.filter { $0.localizedName!.lowercased().contains(input.joined(separator: " ")) }
      return filteredApps.map { DisplayableContainer(name: $0.localizedName!, content: $0.bundleURL!.path, icon: $0.icon!, priority: priority, innerItem: $0) }
    }
  }
}

