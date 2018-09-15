//
//  WebServiceHub.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

final class WebExtHub: ServiceLoader {
  typealias ServiceType = WebExt
  var cachedKey: String = ""
  var cachedProviders: Array<WebExt> = []
  
  static let `default` = WebExtHub()
  private let path = UserDefaults.shared.url(forKey: .appSupportDir)!.appendingPathComponent("Services/web.json")
  private lazy var listener: TonnerreFSDetector = {
    return TonnerreFSDetector(pathes: path.path, callback: filesDidChange)
  }()
  private var serviceTrie = Trie<WebExt>(values: []) { $0.keyword }
  private let queue = DispatchQueue(label: "Tonnerre.WebHub")
  
  private init() {
    listener.start()
    queue.async { [unowned self] in
      for service in WebExt.construct(fromURL: self.path) {
        self.serviceTrie.insert(value: service)
      }
    }
  }
  
  deinit {
    listener.stop()
  }
  
  func _find(keyword: String) -> [WebExt] {
    guard !keyword.isEmpty else { return [] }
    let userDefault = UserDefaults.shared
    return serviceTrie.find(value: keyword)
      .filter { !userDefault.bool(forKey: "\($0.id)+isDisabled") }
  }
  
  private func filesDidChange(events: [TonnerreFSDetector.event]) {
    let add: ()->Void = { [unowned self] in
      for webExt in WebExt.construct(fromURL: self.path) {
        self.serviceTrie.insert(value: webExt)
      }
    }
    
    queue.async { [unowned self] in
      for (path, flags) in events {
        guard path == self.path.path else { continue }
        if flags.contains(.modified) || flags.contains(.created) {
          self.serviceTrie = Trie<WebExt>(values: []) { $0.keyword }
          add()
        } else if flags.contains(.renamed) || flags.contains(.removed) {
          self.serviceTrie = Trie<WebExt>(values: []) { $0.keyword }
        }
      }
    }
  }
}
