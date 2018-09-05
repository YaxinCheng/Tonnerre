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
    listener.start()
    DispatchQueue(label: "Tonnerre.TNEHub").async { [unowned self] in
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
      
      let add: (URL)->Void = { [unowned self] in
        guard
          self.pathWithService[$0.path] == nil,
          let service = TNEScript(scriptPath: $0)
        else { return }
        self.pathWithService[$0.path] = service
        self.serviceTrie.insert(value: service)
      }
      
      let remove: (URL)->Void = {
        guard let service = self.pathWithService[$0.path] else { return }
        self.pathWithService[$0.path] = nil
        self.serviceTrie.remove(value: service)
      }
      
      if flags.contains(.created) || flags.contains(.modified) {
        add(fileURL)
      } else if flags.contains(.removed) {
        remove(fileURL)
      } else if flags.contains(.renamed) {
        if pathWithService[path] == nil {
          add(fileURL)
        } else {
          remove(fileURL)
        }
      }
    }
  }
}
