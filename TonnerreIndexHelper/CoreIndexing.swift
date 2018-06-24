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
    let pathes: [String] = [SearchMode.default.indexTargets, SearchMode.name.indexTargets].reduce([], +).map({$0.path})
    if !pathes.isEmpty {
      self.detector = TonnerreFSDetector(pathes: pathes, callback: self.detectedChanges)
    }
    let centre = NotificationCenter.default
    centre.addObserver(self, selector: #selector(defaultIndexingDidFinish), name: .defaultIndexingDidFinish, object: nil)
    centre.addObserver(self, selector: #selector(documentIndexingDidFinish), name: .documentIndexingDidFinish, object: nil)
  }
  
  private func lostIndeces() -> [SearchMode] {
    let fileManager = FileManager.default
    let allModes: [SearchMode] = [.default, .name, .content]
    let lostIndexes = allModes.filter { !fileManager.fileExists(atPath: $0.indexPath.path) }
    return lostIndexes
  }
  
  func check() {
    let defaultFinished = UserDefaults.standard.bool(forKey: StoredKeys.defaultInxFinished.rawValue)
    let documentFinished = UserDefaults.standard.bool(forKey: StoredKeys.documentInxFinished.rawValue)
    let indexingMode = lostIndeces()
    if (defaultFinished == false && documentFinished == false) || indexingMode.count != 0 {
      let context = getContext()
      let fetchRequest = NSFetchRequest<IndexingDir>(entityName: CoreDataEntities.IndexingDir.rawValue)
      let count = (try? context.count(for: fetchRequest)) ?? 0
      if count == 0 {
        if indexingMode.contains(.default) {
          fullIndex(modes: .default)
        }
        let filteredModes = indexingMode.filter { $0 != .default }
        fullIndex(modes: filteredModes)
      } else {
        recoverFromErrors()
      }
    }
    if defaultFinished == true && documentFinished == true && indexingMode.count == 0 {
      listenToChanges()
    }
  }
 
  // MARK: - index forward
  /**
    Index the required data to the certain index files
   */
  private func fullIndex(modes: SearchMode...) {
    fullIndex(modes: modes)
  }
  
  private func fullIndex(modes: [SearchMode]) {
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
    queue.async { [unowned self] in
      notificationCentre.post(beginNotification)
      let indeces = modes.compactMap({ self.indexes[$0, true] })
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
      } catch {
        #if DEBUG
        debugPrint(error)
        #endif
      }
      context.delete($0)// delete anyway even if it fails
      try? context.save()
    }
    let notificationCentre = NotificationCenter.default
    queue.async { [unowned self] in // Restore for defaults
      notificationCentre.post(Notification(name: .defaultIndexingDidBegin))
      let defaultIndex = self.indexes[.default, true]
      for fd in failedDefault { dealFailure(fd, defaultIndex) }
      let ongoingDefaultURL = ongoingDefault.map({ URL(fileURLWithPath: $0.path!) })
      for od in ongoingDefaultURL { self.addContent(in: od, modes: [.default], indexes: [defaultIndex]) }
      notificationCentre.post(Notification(name: .defaultIndexingDidFinish))
    }
    queue.async { [unowned self] in // Restore for documents
      notificationCentre.post(Notification(name: .documentIndexingDidBegin))
      let nameIndex = self.indexes[.name, true]
      let contentIndex = self.indexes[.content, true]
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
    var queue = [path]
    while !queue.isEmpty {
      let processingURL = queue.removeFirst()// Get the first in the queue
      if processingURL.isSymlink || processingURL.typeIdentifier.starts(with: "dyn") { continue }// skip dynamic or sym files
      do {
        if processingURL.isDirectory {// Directory
          for (mode, index) in zip(searchModes, indexes) where mode.includeDir == true {
            _ = try index.addDocument(atPath: processingURL) // Add to indexes accept directory
          }
          let content = try FileManager.default.contentsOfDirectory(at: processingURL, includingPropertiesForKeys: [.isSymbolicLinkKey, .typeIdentifierKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
          let (dirURL, fileURL) = content.bipartite { $0.isDirectory }// Seperate the content into two parts
          queue.append(contentsOf: fileURL)// Add file urls in the queue
          let filteredDir = dirURL.filter { !FileTypeControl.isExcludedDir(url: $0) && !FileTypeControl.isExcludedURL(url: processingURL) }
          queue.append(contentsOf: filteredDir)// Add filtered directory urls in the queue
          backgroundQ.async { [unowned self] in
            for mode in searchModes {// For each mode remove current dir, and add the up coming dir
              self.safeDelete(data: ["path": processingURL.path, "category": mode.storedInt], dataType: IndexingDir.self)
              for dir in filteredDir {
                let _:IndexingDir? = self.safeInsert(data: ["path": dir.path, "category": mode.storedInt])
              }
            }
          }
        } else {// File
          for (mode, index) in zip(searchModes, indexes) where mode.include(fileURL: processingURL) {// Add file to related index
            _ = try index.addDocument(atPath: processingURL, additionalNote: getAlias(name: processingURL.lastPathComponent))
          }
        }
      } catch {// If error
        backgroundQ.async { [unowned self] in // Insert a failed path to CoreData
          for mode in searchModes {// Add failedPath
            let _: FailedPath? = self.safeInsert(data: ["path": processingURL.path, "reason": "\(error)", "category": mode.storedInt])
          }
        }
      }
      #if DEBUG
      debugPrint(processingURL.path)
      #endif
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
  func listenToChanges() {
    detector.start()
  }
  
  func stopListening() {
    detector.stop()
  }
  /**
   Based on the path url, identify which search mode it belongs to
  */
  private func identify(path: URL) -> [SearchMode] {
    if FileTypeControl.isExcludedURL(url: path) { return [] }
    if FileTypeControl.isExcludedDir(url: path) { return [] }
    if path.typeIdentifier.starts(with: "dyn") { return [] }
    let defaultDir = Set(SearchMode.default.indexTargets)
    if defaultDir.contains(path) { return [.default] }
    let documentDir = Set(SearchMode.name.indexTargets)
    let exclusions = FileTypeControl(types: .media, .image)
    let extensionAnalyze: (URL) -> [SearchMode] = { path in
      if path.isDirectory || exclusions.isInControl(file: path) { return [.name] }
      return [.name, .content]
    }
    if documentDir.contains(path) {
      return extensionAnalyze(path)
    }
    for defaultPath in defaultDir {
      if path.isChildOf(url: defaultPath) { return [.default] }
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
      let relatedIndexes = relatedModes.map({ indexes[$0, true] })
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
    let extraAlias: (String) -> String = { origin in // Get initial of words, such as Activity Manager -> AM
      let elements = origin.components(separatedBy: " ").compactMap({ $0.first }).map({ String($0) })
      return " \(elements.joined())"
    }
    if alias.contains(" ") { alias += extraAlias(alias) }
    if name.contains(" ") { alias += extraAlias(name) }
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
