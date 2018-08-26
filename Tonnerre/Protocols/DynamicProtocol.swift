//
//  DynamicProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 The base protocol that dynamic services loaded from files should conform to
*/
protocol DynamicProtocol: class {
  /**
   The type for services loaded from JSON or TNE files
  */
  typealias ServiceType = DisplayableContainer<String>
  /**
   A trie used to query loaded services
  */
  var serviceTrie: Trie<ServiceType> { get set }
  /**
   Load services with a given URL
   - parameter url: The URL to a specific TNE file or JSON file
   - returns: A list of services in the given file
  */
  static func generateService(from url: URL) -> [ServiceType]
  /**
   Reload services from the files.
   - Note: This is an asynchronized function, and it may not finish at once
  */
  func reload()
}

extension DynamicProtocol {
  /**
   Fill in parameters into the given string template
   - parameter template: a template string with one ore multiple %@ as the placeholder
   - parameter args: arguments used to replace the placeholders
   - returns: a new string with the placeholders replaced by the arguments.
   
      - If the number of arguments is more than the number of placeholders, then the last a few arguments will be joined to one to fill one placeholder.
      - If the number of arguments is less than the number of placeholders, then the template will be returned without filling.
  */
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
   */
  internal func prefetch(fileExtension: String) {
    let appSupDir = UserDefaults.standard.url(forKey: .appSupportDir)!
    let serviceFolder = appSupDir.appendingPathComponent("Services")
    do {
      let contents = try FileManager.default.contentsOfDirectory(at: serviceFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
      let extensions = contents.filter { $0.pathExtension.lowercased() == fileExtension } // Tonnerre Extension File Types
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
