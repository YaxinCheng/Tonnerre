//
//  FileIndexingManager.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

class FileIndexingManager {
  lazy var aliasDict: Dictionary<String, String> = {
    guard let aliasFile = Bundle.main.path(forResource: "alias", ofType: "plist") else {
      return [:]
    }
    return NSDictionary(contentsOfFile: aliasFile) as! [String : String]
  }()
  
  func indexDefault() {
    let mode: SearchMode = .defaultMode
    let targetPaths = mode.indexTargets
    let queue = DispatchQueue.global(qos: .userInitiated)
    queue.async {
      for beginURL in targetPaths {
        self.addContent(in: beginURL, to: mode.index)
      }
    }
  }
  
  func indexDocuments() {
    let modes: [SearchMode] = [.name, .content]
    let targetPaths = modes[0].indexTargets
    let queue = DispatchQueue.global(qos: .utility)
    queue.async {
      for beginURL in targetPaths {
        self.addContent(in: beginURL, to: modes.map({$0.index}))
      }
    }
  }
  
  private func getAlias(name: String) -> String {
    var alias = aliasDict[name, default: ""]
    if alias.contains(" ") {// Get initial of words, such as Activity Manager -> AM
      let elements = alias.components(separatedBy: " ").compactMap({ $0.first }).map({ String($0) })
      alias += " \(elements.joined(separator: ""))"
    }
    return alias
  }
  
  private func addContent(in path: URL, to indexes: TonnerreIndex...) {
    addContent(in: path, to: indexes)
  }
  
  private func addContent(in path: URL, to indexes: [TonnerreIndex]) {
    if path.isSymlink { return }
    var content: [URL] = []
    do {
      for index in indexes where index.type == .nameOnly {
        _ = try index.addDocument(atPath: path)
      }
      if !path.isDirectory {
        for index in indexes {
          _ = try index.addDocument(atPath: path, additionalNote: getAlias(name: path.lastPathComponent))
        }
      } else {
        content = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
      }
    } catch {
      let context = getContext()
      let failedRecord = FailedPath(context: context)
      failedRecord.path = path.path
      failedRecord.reason = "\(error)"
      try? context.save()
    }
    if path.isDirectory {
      let orderedContent = separate(paths: content)
      for filePath in orderedContent[0] {
        addContent(in: filePath, to: indexes)
      }
      for dirPath in orderedContent[1] {
        addContent(in: dirPath, to: indexes)
      }
    }
  }
  
  private func separate(paths: [URL]) -> [[URL]] {
    var result: [[URL]] = [[], []]
    for path in paths {
      if path.isDirectory {
        result[1].append(path)
      } else {
        result[0].append(path)
      }
    }
    return result
  }
}

extension URL {
  var isDirectory: Bool {
    let value = try? resourceValues(forKeys: [.isDirectoryKey])
    return value?.isDirectory ?? false
  }
  
  var isSymlink: Bool {
    let value = try? resourceValues(forKeys: [.isSymbolicLinkKey])
    return value?.isSymbolicLink ?? false
  }
}
