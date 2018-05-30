//
//  CoreIndexing.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

class CoreIndexing {
  // MARK: - Properties
  /**
   A dictionary using file names as keys, and related aliases (if exist) as values
  */
  private lazy var aliasDict: Dictionary<String, String> = {
    guard let aliasFile = Bundle.main.path(forResource: "alias", ofType: "plist") else {
      return [:]
    }
    return NSDictionary(contentsOfFile: aliasFile) as! [String : String]
  }()
  /**
   SearchModel to related exclusion controls
   - defaultMode: []
   - name: extra coding files (e.g.: .pyc or .class) + caches
   - content: extra coding files + caches + media (user cannot search medias with the media content, generally by name only)
  */
  private var controls: [SearchMode: ExclusionControl] = [:]
  /**
   Background queue. When inserting to or deleting from CoreData, they are running in the background
  */
  private let backgroundQ: DispatchQueue = .global(qos: .background)
  /**
   Semaphore. Used to prevent destructive interference for adding to and deleting from CoreData
   */
  private let coreDataSemaphore = DispatchSemaphore(value: 1)
  
  private let indexes = IndexStorage()
  private var detector: TonnerreFSDetector! = nil
  
  init() {
    let pathes: [String] = [SearchMode.defaultMode.indexTargets, SearchMode.name.indexTargets].reduce([], +).map({$0.path})
    if !pathes.isEmpty {
      self.detector = TonnerreFSDetector(pathes: pathes, callback: self.detectedChanges)
    }
    let centre = NotificationCenter.default
    centre.addObserver(self, selector: #selector(defaultIndexingDidFinish), name: .defaultIndexingDidFinish, object: nil)
    centre.addObserver(self, selector: #selector(documentIndexingDidFinish), name: .documentIndexingDidFinish, object: nil)
  }
  
  func check() {
    let defaultFinished = UserDefaults.standard.bool(forKey: StoredKeys.defaultInxFinished.rawValue)
    let documentFinished = UserDefaults.standard.bool(forKey: StoredKeys.documentInxFinished.rawValue)
    if defaultFinished == false && documentFinished == false {
      let context = getContext()
      let fetchRequest = NSFetchRequest<IndexingDir>(entityName: CoreDataEntities.IndexingDir.rawValue)
      let count = (try? context.count(for: fetchRequest)) ?? 0
      if count == 0 {
        fullIndex(modes: .defaultMode)
        fullIndex(modes: .name, .content)
      } else {
        recoverFromErrors()
      }
    }
    if defaultFinished == true && documentFinished == true {
      listenToChanges()
    }
  }
 
  // MARK: - index forward
  /**
    Index the required data to the certain index files
   */
  private func fullIndex(modes: SearchMode...) {
    guard let targetPaths: [URL] = modes.first?.indexTargets else { return }
    for mode in modes {
      for path in targetPaths {
        let _: IndexingDir? = safeInsert(data: ["path": path.path, "category": mode.storedInt])
      }
    }
    let queue = DispatchQueue.global(qos: .utility)
    let notificationCentre = NotificationCenter.default
    let beginNotification = modes.count == 2 ? Notification(name: .documentIndexingDidBegin) : Notification(name: .defaultIndexingDidBegin)
    let endNotification = modes.count == 2 ? Notification(name: .documentIndexingDidFinish) : Notification(name: .defaultIndexingDidFinish)
    for mode in modes { indexes[mode] = TonnerreIndex(filePath: mode.indexPath.path, indexType: mode.indexType) }
    queue.async { [unowned self] in
      notificationCentre.post(beginNotification)
      let indeces = modes.compactMap({ self.indexes[$0] })
      for beginURL in targetPaths { self.addContent(in: beginURL, modes: modes, indexes: indeces) }
      notificationCentre.post(endNotification)
    }
  }
  
  /**
   Recover the unfinished indexing and failed indexing
  */
  private func recoverFromErrors() {
    let context = getContext()
    let queryErrors: (String)->[NSManagedObject] = {// Function to query from CoreData
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: $0)
      return (try? context.fetch(fetchRequest)) ?? []
    }
    guard
      let failedPathes = queryErrors(CoreDataEntities.FailedPath.rawValue) as? [FailedPath],
      let ongoingPathes = queryErrors(CoreDataEntities.IndexingDir.rawValue) as? [IndexingDir]
    else { return }// Get failedPath and unfinished IndexingDir
    let (failedDefault, failedDocuments) = failedPathes.bipartite { $0.category == 0 }// Separate default & docs
    let (ongoingDefault, ongoingDocuments) = ongoingPathes.bipartite { $0.category == 0 }
    let queue = DispatchQueue.global(qos: .utility)
    let dealFailure: (FailedPath, TonnerreIndex) -> Void = { [unowned self] in// FailedPath dealing
      // Re-try adding the FailedPath into the index files, but do not recursively go to its content
      do {
        let pathURL = URL(fileURLWithPath: $0.path!)
        _ = try $1.addDocument(atPath: pathURL, additionalNote: self.getAlias(name: pathURL.lastPathComponent))
      } catch { debugPrint(error) }
      context.delete($0)// delete anyway even if it fails
      try? context.save()
    }
    let notificationCentre = NotificationCenter.default
    queue.async { [unowned self] in // Restore for defaults
      notificationCentre.post(Notification(name: .defaultIndexingDidBegin))
      let defaultIndex = self.indexes[.defaultMode]
      for fd in failedDefault { dealFailure(fd, defaultIndex) }
      let ongoingDefaultURL = ongoingDefault.map({ URL(fileURLWithPath: $0.path!) })
      for od in ongoingDefaultURL { self.addContent(in: od, modes: [.defaultMode], indexes: [defaultIndex]) }
      notificationCentre.post(Notification(name: .defaultIndexingDidFinish))
    }
    queue.async { [unowned self] in // Restore for documents
      notificationCentre.post(Notification(name: .documentIndexingDidBegin))
      let nameIndex = self.indexes[.name]
      let contentIndex = self.indexes[.content]
      for fd in failedDocuments {
        let index = fd.category == 1 ? nameIndex : contentIndex
        dealFailure(fd, index)
      }
      for od in ongoingDocuments {
        let url = URL(fileURLWithPath: od.path!)
        self.addContent(in: url, modes: [.name, .content], indexes: [nameIndex, contentIndex])
      }
      notificationCentre.post(Notification(name: .documentIndexingDidFinish))
    }
  }
  
  /**
   The key function to recursively iterate through the file system structure and add files to index files
   - parameter path: the path to begin. This path and its children content (if path is a directory) will be added to the index files
   - parameter searchModes: the search modes are used to find the correct exclusion lists and correct index files
   */
  private func addContent(in path: URL, modes searchModes: SearchMode..., indexes: [TonnerreIndex]) {
    addContent(in: path, modes: searchModes, indexes: indexes)
  }
  
  /**
   The key function to recursively iterate through the file system structure and add files to index files
   - parameter path: the path to begin. This path and its children content (if path is a directory) will be added to the index files
   - parameter searchModes: the search modes are used to find the correct exclusion lists and correct index files
  */
  private func addContent(in path: URL, modes searchModes: [SearchMode], indexes: [TonnerreIndex]) {
    if path.isSymlink { return }// Do not add symlink to the index file
    var content: [URL] = []// The content of the path (if the path is a directory)
    do {
      if !path.isDirectory {// If it is not a directory
        for (mode, index) in zip(searchModes, indexes) {// Add file to related index files
          let fileExtension = path.pathExtension.lowercased()// get the extension
          if (controls[mode]?.contains(fileExtension) ?? false) { continue }// Exclude the unwanted types
          _ = try index.addDocument(atPath: path, additionalNote: getAlias(name: path.lastPathComponent))// add to the index file
        }
      } else {// If it is a directory
        for (mode, index) in zip(searchModes, indexes) where mode.includeDir == true {// Add to the index file if the index file accepts directory
          _ = try index.addDocument(atPath: path)
        }
        // Find all content files of this path
        content = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
      }
    } catch {// If any error happened
      backgroundQ.async { [unowned self] in // Insert a failed path to CoreData
        for mode in searchModes {
          let _: FailedPath? = self.safeInsert(data: ["path": path.path, "reason": "\(error)", "category": mode.storedInt])
        }
      }
    }
    if path.isDirectory {// This is simply for the tail recursion to separate from above
      let (directories, files) = content.bipartite { $0.isDirectory }// Separate file URLs and directory URLs
      for filePath in files { addContent(in: filePath, modes: searchModes, indexes: indexes) }// Add files to index files
      // Filter out certain directory with specific names: cache, logs, locales
      let filteredDir = directories.filter { !ExclusionControl.isExcludedDir(name: $0.lastPathComponent.lowercased()) && !ExclusionControl.isExcludedURL(url: $0) }
      backgroundQ.async { [unowned self] in
        for mode in searchModes { // When each single file is indexed, we remove the path from CoreData
          self.safeDelete(data: ["path": path.path, "category": mode.storedInt], dataType: IndexingDir.self)
        // Then we add each sub-directory in this path to the CoreData
          for dirPath in filteredDir {
              let _: IndexingDir? = self.safeInsert(data: ["path": dirPath.path, "category": mode.storedInt])
          }
      }// So finally, there will be no data left in the IndexingDir
      }
      debugPrint(path)
      for dirPath in filteredDir { addContent(in: dirPath, modes: searchModes, indexes: indexes) }// Recursion to add each of them
    }
  }
  
  @objc private func defaultIndexingDidFinish() {
    UserDefaults.standard.set(true, forKey: StoredKeys.defaultInxFinished.rawValue)
  }
  
  @objc private func documentIndexingDidFinish() {
    UserDefaults.standard.set(true, forKey: StoredKeys.documentInxFinished.rawValue)
    backgroundQ.async { [unowned self] in
      self.safeDelete(data: [:], dataType: IndexingDir.self)
    }
    detector.start()
  }
  
  // MARK: - File System Change detection
  private func listenToChanges() {
    detector.start()
  }
  
  private func stopListening() {
    detector.stop()
  }
  /**
   Based on the path url, identify which search mode it belongs to
  */
  private func identify(path: URL) -> [SearchMode] {
    if ExclusionControl.isExcludedURL(url: path) { return [] }
    if ExclusionControl.isExcludedDir(name: path.lastPathComponent) { return [] }
    let defaultDir = Set(SearchMode.defaultMode.indexTargets)
    if defaultDir.contains(path) { return [.defaultMode] }
    let documentDir = Set(SearchMode.name.indexTargets)
    let codingExclusion = ExclusionControl(type: .coding)
    let mediaExclusion = ExclusionControl(type: .media)
    let extensionAnalyze: (URL) -> [SearchMode] = { path in
      let extensionName = path.pathExtension
      if codingExclusion.contains(extensionName) || codingExclusion.contains(extensionName) { return [] }
      if path.isDirectory || mediaExclusion.contains(extensionName) { return [.name] }
      return [.name, .content]
    }
    if documentDir.contains(path) {
      return extensionAnalyze(path)
    }
    for defaultPath in defaultDir {
      if path.isChildOf(url: defaultPath) { return [.defaultMode] }
    }
    for documentPath in documentDir {
      if path.isChildOf(url: documentPath) { return extensionAnalyze(path) }
    }
    return []
  }
  
  /**
   FileSystem event detected
  */
  private func detectedChanges(events: [TonnerreFSDetector.event]) {
    let created = TonnerreFSEvent.created.rawValue
    let renamed = TonnerreFSEvent.renamed.rawValue
    let removed = TonnerreFSEvent.removed.rawValue
    
    for event in events {
      let (path, changes) = event
      let totalEvents = changes.reduce(0, {$0 | $1.rawValue})
      let pathURL = URL(fileURLWithPath: path)
      let relatedModes = identify(path: pathURL)
      let relatedIndexes = relatedModes.map({ indexes[$0] })
      do {
        if totalEvents & created == created {
          for index in relatedIndexes {
            _ = try index.addDocument(atPath: pathURL)
          }
        } else if totalEvents & renamed == renamed {
          let fileManager = FileManager.default
          for index in relatedIndexes {
            let exist = fileManager.fileExists(atPath: path)
            if exist == false {
              _ = index.removeDocument(atPath: pathURL)
            } else {
              _ = try index.addDocument(atPath: pathURL)
            }
          }
        } else if totalEvents & removed == removed {
          for index in relatedIndexes {
            _ = index.removeDocument(atPath: pathURL)
          }
        }
      } catch {
        for mode in relatedModes {
          let _: FailedPath? = safeInsert(data: ["category": mode.storedInt, "path": path, "reason": "\(error)"])
        }
      }
    }
  }
  
  // MARK: - Helper functions
  /**
   Get alias for specific file names
   
   - parameter name: a file name. An alias is generated or retrieved based on the name
   - returns: an alias generated by compact the first letter of each word in the name or retrieved from the file
   */
  private func getAlias(name: String) -> String {
    var alias = aliasDict[name, default: ""]
    if alias.contains(" ") {// Get initial of words, such as Activity Manager -> AM
      let elements = alias.components(separatedBy: " ").compactMap({ $0.first }).map({ String($0) })
      alias += " \(elements.joined(separator: ""))"
    }
    return alias
  }
  
  /**
   Insert a new data safely (avoid duplicates) into the CoreData
   - parameter data: A dictionary with keys as attributes of the object, and values as related values
   - returns: nil for not inserted (either failed or data already existed), the object itself for the success
  */
  private func safeInsert<T: NSManagedObject>(data: [String: Any]) -> T? {
    let context = getContext()
    let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
    let queryStr = data.keys.map({ $0 + "=%@" }).joined(separator: " AND ")
    let query = data.reduce([], {$0 + [$1.value]})
    fetchRequest.predicate = NSPredicate(format: queryStr, argumentArray: query)
    defer { coreDataSemaphore.signal() }
    coreDataSemaphore.wait()
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
  
  /**
   Delete a data safely (avoid duplicates) into the CoreData
   - parameter data: A dictionary with keys as attributes of the object, and values as related values
   - parameter dataType: The dataType is used to locate the entityName in the CoreData
   */
  private func safeDelete<T: NSManagedObject>(data: [String: Any], dataType: T.Type) {
    let context = getContext()
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(T.self)")
    if !data.isEmpty {
      let queryStr = data.keys.map({ $0 + "=%@" }).joined(separator: " AND ")
      let query = data.reduce([], {$0 + [$1.value]})
      fetchRequest.predicate = NSPredicate(format: queryStr, argumentArray: query)
    }
    let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    coreDataSemaphore.wait()
    _ = try? context.execute(batchDelete)
    try? context.save()
    coreDataSemaphore.signal()
  }
}
