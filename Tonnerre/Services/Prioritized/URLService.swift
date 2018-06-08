//
//  URLService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct URLService: TonnerreService {
  let keyword: String = ""
  let arguments: [String] = ["link"]
  let hasPreview: Bool = false
  var icon: NSImage {
    guard let defaultBrowser = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://google.ca")!) else { return #imageLiteral(resourceName: "safari") }
    let defaultIcon = NSWorkspace.shared.icon(forFile: defaultBrowser.path)
    defaultIcon.size = NSSize(width: 64, height: 64)
    return defaultIcon
  }
  
  func prepare(input: [String]) -> [Displayable] {
    let query = input.joined()
    guard query.starts(with: "http"), let url = URL(string: query) else { return [] }
    let defaultBrowserName = NSWorkspace.shared.urlForApplication(toOpen: url)?.lastPathComponent ?? "your default browser"
    let webRequest = BaseDisplayItem(name: url.absoluteString, content: "Open URL in \(defaultBrowserName)", icon: url.icon, innerItem: url)
    return [webRequest]
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = (source as? BaseDisplayItem<URL>)?.innerItem else { return }
    NSWorkspace.shared.open(request)
  }
}
