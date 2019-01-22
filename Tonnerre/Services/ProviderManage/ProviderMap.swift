//
//  ProviderMap.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

enum ProviderMapError: Error {
  case idExists(id: String)
}

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
          try self.register(provider: provider)
          TonnerreInterpreter.serviceIDTrie.insert(value: provider.id, key: provider.keyword)
        }
      } catch {
        #if DEBUG
        print("Load scripting failed", error)
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
  
  func register(provider: ServiceProvider) throws {
    if registeredProviders[provider.id] != nil {
      throw ProviderMapError.idExists(id: provider.id)
    }
    registeredProviders[provider.id] = provider
  }
  
  func unregister(provider: ServiceProvider) {
    registeredProviders[provider.id] = nil
  }
  
  func retrieve(byID id: String) -> ServiceProvider? {
    return registeredProviders[id] ?? BuiltInProviderMap.retrieveType(baseOnID: id)?.init()
  }
  
  var defaultProvider: ServiceProvider? {
    let id = DefaultProvider.id ?? ""
    return retrieve(byID: id)
  }
  
  private func filesDidChange(events: [TonnerreFSDetector.event]) {
    let add: (URL)->Void = { [unowned self] in
      guard
        self.pathWithService[$0.path] == nil,
        let provider = TNEServiceProvider(scriptPath: $0)
      else { return }
      do {
        try self.register(provider: provider)
        self.pathWithService[$0.path] = provider
        TonnerreInterpreter.serviceIDTrie.insert(value: provider.id, key: provider.keyword)
      } catch {
        #if DEBUG
        print("file change add error", error)
        #endif
      }
    }
    
    let remove: (URL)->Void = {
      guard let provider = self.pathWithService[$0.path] else { return }
      self.pathWithService[$0.path] = nil
      self.unregister(provider: provider)
      TonnerreInterpreter.serviceIDTrie.remove(value: provider.id, key: provider.keyword)
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
