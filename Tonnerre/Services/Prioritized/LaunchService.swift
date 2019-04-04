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
    let aliasFile = Bundle.main.path(forResource: "alias", ofType: "plist")!
    return NSDictionary(contentsOfFile: aliasFile) as! [String: String]
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
          splitCamelCaseNames(name: fileName).joined(separator: " ")]
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
  
  /// Split camel case names to individual words
  /// - parameter name: the name needs to be splitted
  /// - returns: an array of words from the name
  ///
  /// E.g.: "camelCase" -> "camel Case"
  private func splitCamelCaseNames(name: String) -> [String] {
    var names: [Substring] = []
    var startIndex = name.startIndex
    var endIndex = name.index(after: startIndex)
    while endIndex != name.endIndex {
      if CharacterSet.uppercaseLetters.contains(name.unicodeScalars[endIndex]) {
        names.append(name[startIndex ..< endIndex])
        startIndex = endIndex
      }
      endIndex = name.index(after: endIndex)
    }
    names.append(name[startIndex...])
    return names.map(String.init)
  }
}
