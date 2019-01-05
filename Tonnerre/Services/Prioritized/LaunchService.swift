//
//  LaunchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct LaunchService: BuiltInProvider {
  let keyword: String = ""
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  let alterContent: String? = "Show selected app in Finder"
  
  private static let aliasDict: [String: String] = {
    let aliasFile = Bundle.main.path(forResource: "alias", ofType: "plist")!
    return NSDictionary(contentsOfFile: aliasFile) as! [String: String]
  }()
  
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    guard let index = IndexFactory.default else { return [] }
    let query = input.joined(separator: " ")
    let result = index.search(query: query + "*", limit: 5 * 9, options: .default)
    return result.map {
      let fileName: String = $0.deletingPathExtension().lastPathComponent
      let name: String
      if $0.pathExtension == "prefPane" {
        name = LaunchService.aliasDict[fileName, default: fileName.unicodeScalars.reduce("") {
          if CharacterSet.uppercaseLetters.contains($1) {
            if $0.isEmpty { return String($1) }
            else if CharacterSet.uppercaseLetters.contains($0.unicodeScalars.last!) {
              return $0 + String($1)
            } else {
              return $0 + " " + String($1)
            }
          } else {
            return $0 + String($1)
          }
        }]
      } else { name = fileName }
      return DisplayableContainer(name: name, content: $0.path, icon: NSWorkspace.shared.icon(forFile: $0.path),innerItem: $0)
    }.sorted {
      let firstTime = LaunchOrder.retrieveTime(with: ($0 as! DisplayableContainer<URL>).innerItem!.absoluteString)
      let secondTime = LaunchOrder.retrieveTime(with: ($1 as! DisplayableContainer<URL>).innerItem!.absoluteString)
      return firstTime > secondTime
    }
  }
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    guard let appURL = (service as? DisplayableContainer<URL>)?.innerItem else { return }
    LaunchOrder.save(with: appURL.absoluteString)
    let workspace = NSWorkspace.shared
    if withCmd {
      workspace.activateFileViewerSelecting([appURL])
    } else {
      workspace.open(appURL)
    }
  }
}
