//
//  LaunchServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct LaunchService: BuiltInProvider {
  let defaultKeyword: String = ""
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  let alterContent: String? = "Show selected app in Finder"
  
  private static let aliasDict: [String: String] = {
    let content: Result<[String : String], Error> = PropertyListSerialization.read(fileName: "alias")
    switch content {
    case .success(let aliasFile): return aliasFile
    case .failure(let error):
      Logger.error(file: "\(LaunchService.self)", "Alias reading Error: %{PUBLIC}@", error.localizedDescription)
      return [:]
    }
  }()
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    guard let index = IndexFactory.default else { return [] }
    let query = input.joined(separator: " ")
    let result = index.search(query: query + "*", limit: 5 * 9, options: .default)
    return result.map {
      let fileName: String = $0.deletingPathExtension().lastPathComponent
      let name: String
      if $0.pathExtension == "prefPane" {
        name = LaunchService.aliasDict[fileName, default:
          fileName.splitCamelCase().joined(separator: " ")]
      } else { name = fileName }
      return DisplayContainer(name: name, content: $0.path, icon: NSWorkspace.shared.icon(forFile: $0.path), innerItem: $0)
    }.sorted {
      let firstTime = LaunchOrder.retrieveTime(with: ($0 as! DisplayContainer<URL>).innerItem!.absoluteString)
      let secondTime = LaunchOrder.retrieveTime(with: ($1 as! DisplayContainer<URL>).innerItem!.absoluteString)
      return firstTime > secondTime
    }
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    guard let appURL = (service as? DisplayContainer<URL>)?.innerItem else { return }
    LaunchOrder.save(with: appURL.absoluteString)
    let workspace = NSWorkspace.shared
    if withCmd {
      workspace.activateFileViewerSelecting([appURL])
    } else {
      workspace.open(appURL)
    }
  }
}
