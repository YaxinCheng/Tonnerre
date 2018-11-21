//
//  ProviderMap.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

final class ProviderMap {
  static let shared = ProviderMap()
  private(set) var registeredProviders: [String: ServiceProvider] = [:]
  
  private let path = UserDefaults.shared.url(forKey: .appSupportDir)!.appendingPathComponent("Services")
  private lazy var listener: TonnerreFSDetector = {
    return TonnerreFSDetector(pathes: path.path, callback: filesDidChange)
  }()
  private var pathWithService = Dictionary<String, TNEServiceProvider>()
  private let queue = DispatchQueue(label: "Tonnerre.TNEHub")
  private init() {
    queue.async { [unowned self] in
      do {
        let contents = try FileManager.default.contentsOfDirectory(at: self.path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
        for fileURL in contents where fileURL.pathExtension == "tne" {
          guard let provider = TNEServiceProvider(scriptPath: fileURL) else { continue }
          self.pathWithService[fileURL.path] = provider
          self.register(provider: provider)
          TonnerreInterpreter.serviceIDTrie.insert(key: provider.keyword, value: provider.id)
        }
      } catch {
        #if DEBUG
        print("Load scripting failed")
        #endif
      }
    }
  }
  
  func start() {
    listener.start()
  }
  
  func stop() {
    listener.stop()
  }
  
  func register(provider: ServiceProvider) {
    registeredProviders[provider.id] = provider
  }
  
  func unregister(provider: ServiceProvider) {
    registeredProviders[provider.id] = nil
  }
  
  func retrieve(byID id: String) -> ServiceProvider? {
    return registeredProviders[id] ?? BuiltInProviderMap.retrieveType(baseOnID: id)?.init()
  }
  
  var defaultProvider: ServiceProvider? {
    let userDefault = UserDefaults.shared
    let id = userDefault.string(forKey: "Tonnerre.Provider.Default") ?? ""
    return retrieve(byID: id)
  }
  
  private func filesDidChange(events: [TonnerreFSDetector.event]) {
    let add: (URL)->Void = { [unowned self] in
      guard
        self.pathWithService[$0.path] == nil,
        let provider = TNEServiceProvider(scriptPath: $0)
      else { return }
      self.pathWithService[$0.path] = provider
      self.register(provider: provider)
      TonnerreInterpreter.serviceIDTrie.insert(key: provider.keyword, value: provider.id)
    }
    
    let remove: (URL)->Void = {
      guard let provider = self.pathWithService[$0.path] else { return }
      self.pathWithService[$0.path] = nil
      self.unregister(provider: provider)
      TonnerreInterpreter.serviceIDTrie.remove(key: provider.keyword, value: provider.id)
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
