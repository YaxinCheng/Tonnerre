//
//  ExtensionHub.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-27.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

final class ExtensionHub {
  private let path = UserDefaults.shared.url(forKey: .appSupportDir)!.appendingPathComponent("Services")
  private lazy var listener: TonnerreFSDetector = {
    return TonnerreFSDetector(pathes: path.path, callback: filesDidChange)
  }()
  private var serviceTrie = Trie<TNEScript>(values: []) { $0.keyword }
  private var servicesWithPaths: [URL: TNEScript] = [:]
  private static let validExtensions = [".py", ".scpt"]
  
  static let instance = ExtensionHub()
  
  private init() {
    DispatchQueue(label: "Tonnerre.ExtensionHub").async { [unowned self] in
      do {
        let contents = try FileManager.default.contentsOfDirectory(at: self.path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
        for fileURL in contents {
          guard let service = ExtensionHub.generateService(from: fileURL) else { continue }
          self.servicesWithPaths[fileURL] = service
          self.serviceTrie.insert(value: service)
        }
        self.listener.start()
      } catch {
        #if DEBUG
        print("Load scripting failed")
        #endif
      }
    }
  }
  
  deinit {
    listener.stop()
  }
  
  func find(keyword: String) -> [TNEScript] {
    guard !keyword.isEmpty else { return [] }
    let userDefault = UserDefaults.standard
    let possibleScripts = serviceTrie.find(value: keyword)
      .filter { !userDefault.bool(forKey: "\($0.keyword)_\($0.name)_\($0.content)+isDisabled") }
    return possibleScripts
  }
  
  private func filesDidChange(events: [TonnerreFSDetector.event]) {
    for (path, flags) in events {
      let fileURL = URL(fileURLWithPath: path)
      guard fileURL.pathExtension == "tne" else { continue }
      if flags.contains(.created) || flags.contains(.modified) {
        guard
          let service = ExtensionHub.generateService(from: fileURL),
          servicesWithPaths[fileURL] == nil
        else { return }
        servicesWithPaths[fileURL] = service
        serviceTrie.insert(value: service)
      } else if flags.contains(.removed) {
        guard let service = servicesWithPaths[fileURL] else { return }
        servicesWithPaths[fileURL] = nil
        serviceTrie.remove(value: service)
      }
    }
  }
  
  private func remove(filePath fileURL: URL) {
    guard let service = servicesWithPaths[fileURL] else { return }
    servicesWithPaths[fileURL] = nil
    serviceTrie.remove(value: service)
  }
}

// This extension stores all the helper functions
extension ExtensionHub {
  // MARK: - Constructions
  private static func generateService(from url: URL) -> TNEScript? {
    var script: URL! = nil
    for ext in validExtensions {
      let validPath = url.appendingPathComponent("main" + ext)
      if FileManager.default.fileExists(atPath: validPath.path) {
        script = validPath
        break
      }
    }
    guard script != nil else { return nil }
    let iconURL = url.appendingPathComponent("icon.png")
    let fileIcon = NSImage(contentsOf: iconURL)
    let jsonURL = url.appendingPathComponent("description.json")
    do {
      let jsonData = try Data(contentsOf: jsonURL)
      let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? Dictionary<String, String>
      guard
        let descriptionObj = jsonObject,
        let name = descriptionObj["name"],
        let keyword = descriptionObj["keyword"]
        else { return nil }
      let icon: NSImage
      if fileIcon != nil { icon = fileIcon! }
      else if let iconPath = descriptionObj["icon"], let iconFromPath = NSImage(contentsOfFile: iconPath) {
        icon = iconFromPath
      } else { icon = #imageLiteral(resourceName: "tonnerre_extension").tintedImage(with: TonnerreTheme.current.imgColour) }
      return TNEScript(keyword: keyword, name: name, content: descriptionObj["content"] ?? "", icon: icon, scriptPath: script)
    } catch {
      #if DEBUG
      print("Error happened in generate service: ", error)
      #endif
      return nil
    }
  }
}
