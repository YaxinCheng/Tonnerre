//
//  TNEServiceProvider.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

/**
 All the extended service providers are constructed as
 this TNEServiceProvider. It now supports scripts in
 `Python`, `AppleScript`, and a simple `JSON`.
 
 Three important components inside a TNE extension:
 1. `description.json`
    - this defines how the provider and its services will
      be shown on the screen
 2. `icon.png`/`icon_dark.png`
    - this is the icon file for the provider and its
      services. `icon.png` is the first choice for icon
      in light mode, while another for dark mode. However,
      when one is missing, another one will be used anyway.
    - Suggested size: 72 x 72
 3. `main.{json, py, scpt}`
    - this is the script defines the functionality of your
     provider.
    - warning: it can only be named `main`, with the correct
     extension. Otherwise, it would not be run correctly
 */
struct TNEServiceProvider: ServiceProvider {
  let id: String
  let keyword: String
  let name: String
  let content: String
  var alterContent: String?
  let argLowerBound: Int
  let argUpperBound: Int
  /// A TNE Script is executed through its executor
  private let executor: TNEExecutor
  let placeholder: String
  var icon: NSImage {
    return iconPack.icon
  }
  
  /**
   A pack of two icons, and it presents the suitable
   one based on the current system theme
  */
  private struct IconPack {
    let _iconLight: NSImage?
    let _iconDark: NSImage?
    
    var icon: NSImage {
      if UserDefaults.standard.value(forKey: "AppleInterfaceStyle") == nil {
        return _iconLight ?? _iconDark ?? #imageLiteral(resourceName: "notFound")
      } else {
        return _iconDark ?? _iconLight ?? #imageLiteral(resourceName: "notFound")
      }
    }
  }
  private let iconPack: IconPack
  
  /// Build with a given TNE Script path
  ///
  /// - parameter scriptPath: The filePath to the given TNE Script
  /// - note: construction may fail if the given TNE Script cannot be parsed correctly
  init?(scriptPath: URL) {
    do {
      executor = try TNEServiceProvider.createExecutor(basedOn: scriptPath)
      let descriptJSON: JSON? = try {
        let descriptJSONPath = $0.appendingPathComponent("description.json")
        let descriptJSONData = try Data(contentsOf: descriptJSONPath)
        return JSON(data: descriptJSONData)
      }(scriptPath)
      guard descriptJSON != nil else { return nil }
      iconPack = TNEServiceProvider.buildIconPack(descriptionJSON: descriptJSON!, path: scriptPath)
      id = "Tonnerre.Provider.Extension.\(scriptPath.deletingPathExtension().lastPathComponent)"
      guard
        let keyword = (descriptJSON!["keyword"] as? String)?.lowercased(),
        let name: String = descriptJSON!["name"],
        let content: String = descriptJSON!["content"]
      else { return nil }
      (self.keyword, self.name, self.content) = (keyword, name, content)
      argLowerBound = descriptJSON!["argLowerBound", default: 0]
      argUpperBound = descriptJSON!["argUpperBound", default: .max]
      alterContent  = descriptJSON!["alterContent", default: ""]
      placeholder   = descriptJSON!["placeholder", default: keyword]
    } catch {
      #if DEBUG
      print("\(error), path: \(scriptPath)")
      #endif
      return nil
    }
  }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    return [executor.prepare(withInput: input, provider: self)]
  }
  
  func supply(withInput input: [String], callback: @escaping ([DisplayItem])->Void) {
    do {
      guard
        !(argLowerBound == argUpperBound && argUpperBound == 0),
        let returnedJSON = try executor.execute(withArguments: .supply(input: input))
      else {
        callback([])
        return
      }
      let result: [DisplayItem] = returnedJSON.compactMap { _, value in
        guard
          let dict      = value as? [String: Any],
          let name      = dict["name"] as? String,
          let content   = dict["content"] as? String,
          let innerItem = dict["innerItem"]
        else { return nil }
        let alterContent = dict["alterContent"] as? String
        if let stringInner = innerItem as? String,
          (stringInner.starts(with: "http://") || stringInner.starts(with: "https://")),
          let urlInner = URL(string: stringInner) {
          return DisplayContainer(name: name, content: content, icon: icon,
                                      alterContent: alterContent ?? self.alterContent,
                                      innerItem: urlInner, placeholder: name)
        } else {
          return DisplayContainer(name: name, content: content, icon: icon,
                                      alterContent: alterContent ?? self.alterContent,
                                      alterIcon: alterIcon, innerItem: innerItem, placeholder: name)
        }
      }
      callback(result)
    } catch TNEExecutor.Error.wrongInputFormatError(information: _) {
      callback([])
    } catch {
      #if DEBUG
      print("error during prepare: \n\(error)\ninput: \(input)\n")
      #endif
      callback([DisplayContainer(name: "Error", content: "\(error)", icon: icon, innerItem: error, placeholder: "")])
    }
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    let inner: Any?
    if let anyInner = (service as? DisplayContainer<Any>)?.innerItem {
      inner = anyInner
    } else if let urlInner = (service as? DisplayContainer<URL>)?.innerItem {
      inner = urlInner.absoluteString
    } else {
      inner = nil
    }
    let name = service.name
    let content = service.content
    do {
      _ = try executor.execute(withArguments: .serve(choice: ["name": name, "content": content, "innerItem": inner as Any, "withCmd": withCmd]))
    } catch {
      #if DEBUG
      print("error during serve: \n\(error)\nwithCmd: \(withCmd)\nservice: \(service)")
      #endif
    }
  }
}

private extension TNEServiceProvider {
  /// Build iconPack for a TNE Script with a its descriptionJSON and the filePath
  /// - parameter descriptionJSON: descriptionJSON of the given TNE Script.
  ///           The icon path may be stored within it
  /// - parameter path: The file path of the TNE Script. Icons may be stored as icon.png
  ///           files in this path
  private static func buildIconPack(descriptionJSON: JSON, path: URL) -> IconPack {
    let inTNELightIconURL = path.appendingPathComponent("icon.png")
    let inTNEDarkIconURL = path.appendingPathComponent("icon_dark.png")
    let lightIconFile = NSImage(contentsOf: inTNELightIconURL)
    let darkIconFile = NSImage(contentsOf: inTNEDarkIconURL)
    
    let getIcon: (String, NSImage?, JSON) -> NSImage? = {
      if let icon = $1 { return icon }
      else if let iconPath = $2[$0] as? String {
        return NSImage(contentsOfFile: iconPath)
      } else { return nil }
    }
    
    let lightIcon = getIcon("icon", lightIconFile, descriptionJSON)
    let darkIcon = getIcon("icon_dark", darkIconFile, descriptionJSON)
    
    return IconPack(_iconLight: lightIcon, _iconDark: darkIcon)
  }
  
  /// Create an executor for this TNE Script
  /// - parameter scriptPath: The file path to this TNE Script.
  ///             Different executor is created based on the script type
  /// - throws:
  ///   - **TNEExecutor.Error.unsupportedScriptType**: when the script is not supported
  ///       to be executed
  private static func createExecutor(basedOn scriptPath: URL) throws -> TNEExecutor {
    let executor: TNEExecutor? =
      PyExecutor(scriptPath: scriptPath) ??
        ASExecutor(scriptPath: scriptPath) ??
        JSONExecutor(scriptPath: scriptPath)
    guard executor != nil else {
      throw TNEExecutor.Error.unsupportedScriptType
    }
    return executor!
  }
}
