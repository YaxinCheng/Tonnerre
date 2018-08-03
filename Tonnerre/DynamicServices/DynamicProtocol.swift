//
//  DynamicProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol DynamicProtocol: class {
  typealias ServiceType = DisplayableContainer<String>
  var serviceTrie: Trie<ServiceType> { get set }
  static func generateService(from url: URL) -> [ServiceType]
  func reload()
}

extension DynamicProtocol {
  internal func fill(template: String, withArguments args: [String]) -> String {
    let placeholderCount = template.components(separatedBy: "%@").count - 1
    guard placeholderCount <= args.count else { return template }
    if placeholderCount == args.count {
      return String(format: template, arguments: args)
    } else {
      let lastArg = args[placeholderCount...].joined(separator: " ")
      let fillInArgs = Array(args[..<placeholderCount]) + [lastArg]
      return String(format: template, arguments: fillInArgs)
    }
  }
  
  /**
   Load TNE/json extensions from the Services folder in the App Support
   - returns: An array of available services, where as the first value is the keyword, and second is how to display it
   */
  internal func prefetch(fileExtension: String) {
    let appSupDir = UserDefaults.standard.url(forKey: StoredKeys.appSupportDir.rawValue)!
    let serviceFolder = appSupDir.appendingPathComponent("Services")
    do {
      let contents = try FileManager.default.contentsOfDirectory(at: serviceFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
      let extensions = contents.filter { $0.pathExtension.lowercased() == fileExtension } // Tonnerre Extension File Type
      for `extension` in extensions {
        for service in Self.generateService(from: `extension`) {
          serviceTrie.insert(value: service)
        }
      }
    } catch {
      #if DEBUG
      print("Error with loading: ", error)
      #endif
    }
  }
}
