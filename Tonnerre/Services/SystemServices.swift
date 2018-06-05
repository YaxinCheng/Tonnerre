//
//  SystemServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol SystemService: TonnerreService {
  
}
extension SystemService {
  var hasPreview: Bool { return false }
}

struct ApplicationService: SystemService {
  let name: String = "Quit program"
  let content: String = "Find and quite a running program"
  let alterContent: String? = "Force quit program"
  let keyword: String = "quit"
  let icon: NSImage = #imageLiteral(resourceName: "Finder")
  var arguments: [String] = []
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let value = (source as? SystemRequest<NSRunningApplication>)?.innerItem else { return }
    if withCmd { value.forceTerminate() }
    else { value.terminate() }
  }

  func prepare(input: [String]) -> [Displayable] {
    let workspace = NSWorkspace.shared
    let runningApps = workspace.runningApplications.filter { $0.activationPolicy == .regular }
    return runningApps.compactMap { SystemRequest(name: $0.localizedName!, content: $0.bundleURL!.path, icon: $0.icon!, innerItem: $0) }
  }
}

