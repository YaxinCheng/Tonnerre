//
//  ExtensionHub.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-27.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

final class TNEHub: ServiceLoader {
  typealias ServiceType = TNEScript
  var cachedKey: String = ""
  var cachedProviders: Array<TNEScript> = []
  
  private let path = UserDefaults.shared.url(forKey: .appSupportDir)!.appendingPathComponent("Services")
  private lazy var listener: TonnerreFSDetector = {
    return TonnerreFSDetector(pathes: path.path, callback: filesDidChange)
  }()
  private var serviceTrie = Trie<TNEScript>(values: []) { $0.keyword }
  private var pathWithService = Dictionary<String, TNEScript>()
  private let queue = DispatchQueue(label: "Tonnerre.TNEHub")
  
  static let `default` = TNEHub()
  
  private init() {
    listener.start()
    queue.async { [unowned self] in
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
  
  func _find(keyword: String) -> [TNEScript] {
    guard !keyword.isEmpty else { return [] }
    let userDefault = UserDefaults.shared
    let possibleScripts = serviceTrie.find(value: keyword)
      .filter { !userDefault.bool(forKey: "\($0.path.deletingLastPathComponent())+isDisabled") }
    return possibleScripts
  }
  
  private func filesDidChange(events: [TonnerreFSDetector.event]) {
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
      UserDefaults.shared.removeObject(forKey: "\(service.path)+isDisabled")
    }
    
    queue.async { [unowned self] in
      for (path, flags) in events {
        let fileURL = URL(fileURLWithPath: path)
        guard fileURL.pathExtension == "tne" else { continue }
        if flags.contains(.created) || flags.contains(.modified) {
          add(fileURL)
        } else if flags.contains(.removed) {
          remove(fileURL)
        } else if flags.contains(.renamed) {
          if self.pathWithService[path] == nil {
            add(fileURL)
          } else {
            remove(fileURL)
          }
        }
      }
    }
  }
}
