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
  private var controls: [SearchMode: ExclusionControl] = [:]
  private let backgroundQ: DispatchQueue = .global(qos: .background)
  private let semaphore = DispatchSemaphore(value: 1)
  
  func indexDefault() {
    let mode: SearchMode = .defaultMode
    let targetPaths = mode.indexTargets
    
    for path in targetPaths {
      let _: IndexingDir? = safeInsertRecord(data: ["path": path.path, "category": mode.storedInt])
    }
    
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
    controls[.name] = ExclusionControl(type: .coding)
    controls[.content] = ExclusionControl(types: .coding, .media)
    for mode in modes {// Keep records of the documents we are about to index
      for path in targetPaths {
        let _: IndexingDir? = safeInsertRecord(data: ["path": path.path, "category": mode.storedInt])
      }
    }
    let queue = DispatchQueue.global(qos: .utility)
    queue.async {
      for beginURL in targetPaths {
        self.addContent(in: beginURL, to: modes)
      }
      let userDefault = UserDefaults.standard
      if !userDefault.bool(forKey: StoredKeys.finishedIndexing.rawValue) {
        userDefault.set(true, forKey: StoredKeys.finishedIndexing.rawValue)
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
          let fileExtension = path.pathExtension.lowercased()
          if (controls[mode]?.contains(fileExtension) ?? false) { continue }// Exclude the unwanted files
          _ = try mode.index.addDocument(atPath: path, additionalNote: getAlias(name: path.lastPathComponent))
        }
      } else {
        content = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
      }
    } catch {
      backgroundQ.async {
        let _: FailedPath? = self.safeInsertRecord(data: ["path": path.path, "reason": "\(error)"])
      }
    }
    if path.isDirectory {
      let orderedContent = separate(paths: content)
      for filePath in orderedContent[0] {
        addContent(in: filePath, to: searchModes)
      }
      for mode in searchModes {
        // When each single file is indexed, we remove the path from CoreData
        backgroundQ.async {
          self.safeDeleteRecord(data: ["path": path.path, "category": mode.storedInt], dataType: IndexingDir.self)
        }
        // Then we add each sub-directory in this path to the CoreData
        for dirPath in orderedContent[1] {
          backgroundQ.async {
            let _: IndexingDir? = self.safeInsertRecord(data: ["path": dirPath.path, "category": mode.storedInt])
          }
        }
        // So finally, there will be no data left in the IndexingDir
      }
      debugPrint(path)
      for dirPath in orderedContent[1] {
        let pathName = dirPath.lastPathComponent.lowercased()
        if ExclusionControl.isExcludedDir(name: pathName) { continue }// Exclude the cache folders
        if ExclusionControl.isExcludedURL(url: dirPath) { continue }// Exclude specific URLs not needed for all indexing
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
    let queryStr = data.keys.map({ $0 + "=%@" }).joined(separator: " AND ")
    let query = data.reduce([], {$0 + [$1.value]})
    fetchRequest.predicate = NSPredicate(format: queryStr, argumentArray: query)
    defer { semaphore.signal() }
    semaphore.wait()
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
  
  private func safeDeleteRecord<T: NSManagedObject>(data: [String: Any], dataType: T.Type) {
    let context = getContext()
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(T.self)")
    let queryStr = data.keys.map({ $0 + "=%@" }).joined(separator: " AND ")
    let query = data.reduce([], {$0 + [$1.value]})
    fetchRequest.predicate = NSPredicate(format: queryStr, argumentArray: query)
    let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    semaphore.wait()
    _ = try? context.execute(batchDelete)
    try? context.save()
    semaphore.signal()
  }
}
