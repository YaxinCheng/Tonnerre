//
//  URLService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct URLService: BuiltInProvider {
  let keyword: String = ""
  let argLowerBound: Int = 1
  let icon: NSImage = .safari
  let content: String = "Open typed URL in a browser"
  private let urlRegex = try! NSRegularExpression(pattern: "(\\w+\\.)+[a-z]{2,5}(\\/[a-z0-9?\\-=_&/.]*)*", options: .caseInsensitive)
  private let schemeRegex = try! NSRegularExpression(pattern: "^[a-z][a-z]+:\\/\\/", options: .caseInsensitive)
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    guard let query = input.first, input.count == 1 else { return [] }
    let isURL = query.match(regex: schemeRegex) != nil || query.match(regex: urlRegex) != nil
    guard isURL else { return [] }
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let url: URL
    
    if query.match(regex: schemeRegex) != nil { url = URL(string: encodedQuery)! }
    else { url = URL(string: "https://\(encodedQuery)")! }
    let browsers = Browser.installed
        .sorted { LaunchOrder.retrieveTime(with: $0.name) > LaunchOrder.retrieveTime(with: $1.name) }
    return browsers.map {
      DisplayContainer(name: url.absoluteString, content: "Open URL in \($0.name)", icon: $0.icon, innerItem: url, config: .browser($0))
    }
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    guard
      let service = service as? DisplayContainer<URL>,
      let request = service.innerItem,
      case .browser(let browser)? = service.config
    else { return }
    let browserURL = browser.appURL
    LaunchOrder.save(with: browser.name)
    do {
      _ = try NSWorkspace.shared.open([request], withApplicationAt: browserURL, options: .default, configuration: [:])
    } catch {
      #if DEBUG
      print("URL Service Error:", error)
      #endif
    }
  }
}
