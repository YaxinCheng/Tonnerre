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
  private lazy var aliasDict: Dictionary<String, String> = {
    guard let aliasFile = Bundle.main.path(forResource: "alias", ofType: "plist") else {
      return [:]
    }
    return NSDictionary(contentsOfFile: aliasFile) as! [String : String]
  }()
  
  func indexDefault() {
    let mode: SearchMode = .defaultMode
    let targetPaths = mode.indexTargets
    let queue = DispatchQueue.global(qos: .utility)
    queue.async {
      for beginURL in targetPaths {
        self.addContent(in: beginURL, to: mode)
      }
    }
  }
  
  func indexDocuments() {
    let modes: [SearchMode] = [.name, .content]
    let targetPaths = modes[0].indexTargets
    let queue = DispatchQueue.global(qos: .utility)
    queue.async {
      for beginURL in targetPaths {
        self.addContent(in: beginURL, to: modes)
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
  
  private func addContent(in path: URL, to indexes: SearchMode...) {
    addContent(in: path, to: indexes)
  }
  
  private func addContent(in path: URL, to searchModes: [SearchMode]) {
    if path.isSymlink { return }
    var content: [URL] = []
    do {
      for mode in searchModes where mode.includeDir == true {
        _ = try mode.index.addDocument(atPath: path)
      }
      if !path.isDirectory {
        for mode in searchModes {
          _ = try mode.index.addDocument(atPath: path, additionalNote: getAlias(name: path.lastPathComponent))
        }
      } else {
        content = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
      }
    } catch {
      let _: FailedPath? = safeInsertRecord(data: ["path": path.path, "reason": "\(error)"])
    }
    if path.isDirectory {
      let orderedContent = separate(paths: content)
      for filePath in orderedContent[0] {
        addContent(in: filePath, to: searchModes)
      }
      for mode in searchModes {
        let _: IndexedDir? = safeInsertRecord(data: ["path": path.path, "category": mode.storedInt])
      }
      for dirPath in orderedContent[1] {
        addContent(in: dirPath, to: searchModes)
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
  
  private func safeInsertRecord<T: NSManagedObject>(data: [String: Any]) -> T? {
    let context = getContext()
    let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
    let query = data.reduce([], {$0 + [$1.key, $1.value]})
    fetchRequest.predicate = NSPredicate(format: "%@=%@ AND %@=%@", argumentArray: query)
    if let fetchedCount = try? context.count(for: fetchRequest) {
      if fetchedCount > 0 { return nil }
    }
    let newRecord = T(context: context)
    for (key, value) in data {
      newRecord.setValue(value, forKey: key)
    }
    try? context.save()
    return newRecord
  }
}

extension URL {
  var isDirectory: Bool {
    let value = try? resourceValues(forKeys: [.isDirectoryKey, .isPackageKey])
    guard let isDir = value?.isDirectory, let isPack = value?.isPackage else { return false }
    return isDir && !isPack
  }
  
  var isSymlink: Bool {
    let value = try? resourceValues(forKeys: [.isSymbolicLinkKey, .isAliasFileKey])
    guard let isSymlink = value?.isSymbolicLink, let isAlias = value?.isAliasFile else { return false }
    return isSymlink || isAlias
  }
}
