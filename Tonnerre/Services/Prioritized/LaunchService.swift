//
//  LaunchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct LaunchService: TonnerreService {
  static let keyword: String = ""
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  let alterContent: String? = "Show selected app in Finder"
  
  private static let aliasDict: [String: String] = {
    let aliasFile = Bundle.main.path(forResource: "alias", ofType: "plist")!
    return NSDictionary(contentsOfFile: aliasFile) as! [String: String]
  }()
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    let indexStorage = IndexStorage()
    let index = indexStorage[.default]
    let query = input.joined(separator: " ")
    guard !query.starts(with: "http") else { return [] }
    return index.search(query: query + "*", limit: 9 * 9, options: .default).map {
      let fileName: String = $0.deletingPathExtension().lastPathComponent
      let name: String
      if $0.pathExtension == "prefPane" {
        name = LaunchService.aliasDict[$0.lastPathComponent] ?? fileName
      } else { name = fileName }
      return DisplayableContainer(name: name, content: $0.path, icon: NSWorkspace.shared.icon(forFile: $0.path), priority: priority, innerItem: $0)
    }.sorted {
      let firstTime = LaunchOrder.retrieveTime(with: ($0 as! DisplayableContainer<URL>).innerItem!.absoluteString)
      let secondTime = LaunchOrder.retrieveTime(with: ($1 as! DisplayableContainer<URL>).innerItem!.absoluteString)
      return firstTime > secondTime
    }
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let appURL = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    LaunchOrder.saveOrder(for: appURL.absoluteString)
    let workspace = NSWorkspace.shared
    if withCmd {
      workspace.activateFileViewerSelecting([appURL])
    } else {
      workspace.open(appURL)
    }
  }
}
