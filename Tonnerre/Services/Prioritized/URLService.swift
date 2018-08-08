//
//  URLService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct URLService: TonnerreService {
  static let keyword: String = ""
  let argLowerBound: Int = 1
  var icon: NSImage {
    guard let defaultBrowser = NSWorkspace.shared.urlForApplication(toOpen: URL(string: "https://google.ca")!) else { return .safari }
    let defaultIcon = NSWorkspace.shared.icon(forFile: defaultBrowser.path)
    defaultIcon.size = NSSize(width: 64, height: 64)
    return defaultIcon
  }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard let query = input.first, input.count == 1 else { return [] }
    let urlRegex = try! NSRegularExpression(pattern: "^(https?:\\/\\/)?(\\w+\\.)+[a-z]{2,5}(\\/[a-z0-9?\\-=_&]*)*", options: .caseInsensitive)
    let isURL = urlRegex.numberOfMatches(in: query, options: .anchored, range: NSRange(location: 0, length: query.count)) == 1
    guard isURL else { return [] }
    let url: URL
    if query.starts(with: "http") { url = URL(string: query)! }
    else { url = URL(string: "https://\(query)")! }
    let defaultBrowserName = NSWorkspace.shared.urlForApplication(toOpen: url)?.deletingPathExtension().lastPathComponent ?? "your default browser"
    let webRequest = DisplayableContainer(name: url.absoluteString, content: "Open URL in \(defaultBrowserName)", icon: .safari, innerItem: url)
    return [webRequest]
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    NSWorkspace.shared.open(request)
  }
}
