//
//  WebServiceHub.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

final class WebExtHub {
  static let `default` = WebExtHub()
  private let path = UserDefaults.shared.url(forKey: .appSupportDir)!.appendingPathComponent("Services")
  private lazy var listener: TonnerreFSDetector = {
    return TonnerreFSDetector(pathes: path.path, callback: filesDidChange)
  }()
  private var pathWithServices = Dictionary<String, [WebExt]>()
  private var serviceTrie = Trie<WebExt>(values: []) { $0.keyword }
  private let queue = DispatchQueue(label: "Tonnerre.WebHub")
  
  private init() {
    listener.start()
    queue.async { [unowned self] in
      do {
        let contents = try FileManager.default.contentsOfDirectory(at: self.path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
        for fileURL in contents where fileURL.pathExtension == "json" {
          let services = WebExt.construct(fromURL: fileURL)
          self.pathWithServices[fileURL.path] = services
          for service in services {
            self.serviceTrie.insert(value: service)
          }
        }
      } catch {
        #if DEBUG
        print("Load webext failed")
        #endif
      }
    }
  }
  
  deinit {
    listener.stop()
  }
  
  func find(keyword: String) -> [WebExt] {
    guard !keyword.isEmpty else { return [] }
    let userDefault = UserDefaults.shared
    return serviceTrie.find(value: keyword)
      .filter { !userDefault.bool(forKey: "\($0.id)+isDisabled") }
  }
  
  private func filesDidChange(events: [TonnerreFSDetector.event]) {
    let add: (URL)->Void = { [unowned self] in
      let newWebexs = WebExt.construct(fromURL: $0)
      self.pathWithServices[$0.path] = newWebexs
      for webExt in newWebexs {
        self.serviceTrie.insert(value: webExt)
      }
    }
    let remove: (URL)->Void = { [unowned self] in
      guard let webExts = self.pathWithServices[$0.path] else { return }
      self.pathWithServices[$0.path] = nil
      self.serviceTrie.removeAll(values: Set(webExts))
      let userDefault = UserDefaults.shared
      for webExt in webExts {
        userDefault.removeObject(forKey: "\(webExt.id)+isDisabled")
      }
    }
    
    queue.async { [unowned self] in
      for (path, flags) in events {
        let filePath = URL(fileURLWithPath: path)
        guard filePath.pathExtension == "json" else { continue }
        if flags.contains(.created) {
          add(filePath)
        } else if flags.contains(.removed) {
          remove(filePath)
        } else if flags.contains(.renamed) {
          if self.pathWithServices[path] != nil {
            remove(filePath)
          } else {
            add(filePath)
          }
        } else if flags.contains(.modified) {
          remove(filePath)
          add(filePath)
        }
      }
    }
  }
}
