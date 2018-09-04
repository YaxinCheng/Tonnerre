//
//  ExtensionHub.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-27.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

final class TNEHub {
  private let path = UserDefaults.shared.url(forKey: .appSupportDir)!.appendingPathComponent("Services")
  private lazy var listener: TonnerreFSDetector = {
    return TonnerreFSDetector(pathes: path.path, callback: filesDidChange)
  }()
  private var serviceTrie = Trie<TNEScript>(values: []) { $0.keyword }
  private var pathWithService = Dictionary<String, TNEScript>()
  
  static let `default` = TNEHub()
  
  private init() {
    listener = TonnerreFSDetector(pathes: path.path, callback: filesDidChange)
    listener.start()
    DispatchQueue(label: "Tonnerre.ExtensionHub").async { [unowned self] in
      do {
        let contents = try FileManager.default.contentsOfDirectory(at: self.path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
        for fileURL in contents where fileURL.pathExtension == "tne" {
          guard let service = TNEScript(scriptPath: fileURL) else { continue }
          self.pathWithService[fileURL.path] = service
          self.serviceTrie.insert(value: service)
        }
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
      .filter { !userDefault.bool(forKey: "\($0.path)+isDisabled") }
    return possibleScripts
  }
  
  private func filesDidChange(events: [TonnerreFSDetector.event]) {
    for (path, flags) in events {
      let fileURL = URL(fileURLWithPath: path)
      guard fileURL.pathExtension == "tne" else { continue }
      if flags.contains(.created) || flags.contains(.modified) {
        guard
          pathWithService[path] == nil,
          let service = TNEScript(scriptPath: fileURL)
        else { return }
        pathWithService[path] = service
        serviceTrie.insert(value: service)
      } else if flags.contains(.removed) || flags.contains(.renamed) {
        guard let service = pathWithService[path] else { return }
        pathWithService[path] = nil
        serviceTrie.remove(value: service)
      }
    }
  }
}
