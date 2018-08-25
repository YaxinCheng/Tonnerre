//
//  AppleScriptService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class AppleScriptService: DynamicScriptService {
  let argUpperBound: Int = 1
  
  init() {
    serviceTrie = Trie(values: []) { $0.extraContent as! String }
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      self.prefetch(fileExtension: "tne")
    }
  }
  
  var serviceTrie: Trie<DynamicProtocol.ServiceType>
  static var runningProcess: Process?
  var cachedKey: String?
  var cachedServices: [DynamicProtocol.ServiceType] = []
  static let scriptExtension: String = ".scpt"
  
  func execute(script: DynamicProtocol.ServiceType, runningMode: DynamicScriptMode) throws -> [DisplayProtocol] {
    let fileManager = FileManager.default
    guard let scriptPath = script.innerItem, fileManager.fileExists(atPath: scriptPath) else { return [] }
    switch runningMode {
    case .prepare(input: _): return [DisplayableContainer<Any>(name: script.name, content: script.content, icon: script.icon)]
    case .serve(choice: _):
      let scriptContent = try String(contentsOfFile: scriptPath)
      guard let appleScript = NSAppleScript(source: scriptContent) else { return [] }
      appleScript.executeAndReturnError(nil)
    }
    return []
  }
}
