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
  
  private init() {
    listener.start()
    DispatchQueue(label: "Tonnerre.WebHub").async { [unowned self] in
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
    
  }
}
