//
//  TNEServiceProvider.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct TNEServiceProvider: ServiceProvider {
  let id: String
  let keyword: String
  let name: String
  let content: String
  var alterContent: String?
  let argLowerBound: Int
  let argUpperBound: Int
  let executor: TNEExecutor
  let placeholder: String
  var icon: NSImage {
    return iconPack.icon
  }
  
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
  
  init?(scriptPath: URL) {
    do {
      executor = try createExecutor(basedOn: scriptPath)
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
  
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    return executor.prepare(withInput: input, provider: self)
  }
  
  func supply(withInput input: [String]) -> [DisplayProtocol] {
    do {
      guard
        !(argLowerBound == argUpperBound && argUpperBound == 0),
        let returnedJSON = try executor.execute(withArguments: .supply(input: input))
      else { return [] }
      return returnedJSON.compactMap { _, value in
        guard
          let dict = value as? [String: Any],
          let name      = dict["name"] as? String,
          let content   = dict["content"] as? String,
          let innerItem = dict["innerItem"]
        else { return nil }
        let alterContent = dict["alterContent"] as? String
        if let stringInner = innerItem as? String,
          (stringInner.starts(with: "http://") || stringInner.starts(with: "https://")),
          let urlInner = URL(string: stringInner) {
          return DisplayableContainer(name: name, content: content, icon: icon,
                                      alterContent: alterContent ?? self.alterContent,
                                      innerItem: urlInner, placeholder: name)
        } else {
          return DisplayableContainer(name: name, content: content, icon: icon,
                                      alterContent: alterContent ?? self.alterContent,
                                      alterIcon: alterIcon, innerItem: innerItem, placeholder: name)
        }
      }
    } catch {
      #if DEBUG
      print("error during prepare: \n\(error)\ninput: \(input)\n")
      #endif
      return [DisplayableContainer(name: "Error", content: "\(error)", icon: icon, innerItem: error, placeholder: "")]
    }
  }
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    let inner: Any?
    if let anyInner = (service as? DisplayableContainer<Any>)?.innerItem {
      inner = anyInner
    } else if let urlInner = (service as? DisplayableContainer<URL>)?.innerItem {
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
}
