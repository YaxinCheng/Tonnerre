//
//  CoreIndexing.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import TonnerreSearch

final class CoreIndexing {
  
  deinit {
    stopListening()
  }
  
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
  
  private var indexes = IndexStorage()
  private var detector: TonnerreFSDetector! = nil
  
  init() {
    let pathes: [String] = [SearchMode.default.targetFilePaths, SearchMode.name.targetFilePaths]
      .reduce([], +).map { $0.path }
    if !pathes.isEmpty {
      self.detector = TonnerreFSDetector(pathes: pathes,
                                         filterOptions: [.skipHiddenItems, .skipHiddenDescendants, .skipPakcageDescendants],
                                         callback: detectedChanges)
    }
    let centre = NotificationCenter.default
    centre.addObserver(forName: .defaultIndexingDidFinish, object: nil, queue: .main) { _ in
      UserDefaults.standard.set(true, forKey: .defaultInxFinished)
    }
    centre.addObserver(forName: .documentIndexingDidFinish, object: nil, queue: .main) { _ in
      UserDefaults.standard.set(true, forKey: .documentInxFinished)
    }
  }
  
  private func loadIndices(modes: [SearchMode]) {
    for mode in modes {
      indexes.populate(mode)
    }
  }
  
  private func lostIndeces() -> [SearchMode] {
    let fileManager = FileManager.default
    let allModes: [SearchMode] = [.default, .name, .content]
    let lostIndexes = allModes.filter { !fileManager.fileExists(atPath: $0.indexFileURL.path) }
    return lostIndexes
  }
  
  var defaultFinished: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: .defaultInxFinished)
      if newValue == true && documentFinished {
        listenToChanges()
      }
    } get {
      return UserDefaults.standard.bool(forKey: .defaultInxFinished)
    }
  }
  
  var documentFinished: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: .documentInxFinished)
      if newValue == true && defaultFinished {
        listenToChanges()
      }
    } get {
      return UserDefaults.standard.bool(forKey: .documentInxFinished)
    }
  }
  
  func check() {
    let lostIndexes = lostIndeces()
    loadIndices(modes: [.default, .name, .content])
    if defaultFinished == false || lostIndexes.contains(.default) {
      defaultFinished = false
      fullIndex(modes: .default)
    }
    if documentFinished == false || lostIndexes.contains(.name) || lostIndexes.contains(.content) {
      documentFinished = false
      let targetModes = lostIndexes.filter { $0 != .default }
      if targetModes.isEmpty {
        fullIndex(modes: .name, .content)
      } else {
        fullIndex(modes: targetModes)
      }
    }
    if defaultFinished == true && documentFinished == true && lostIndexes.count == 0 {
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
    guard let targetPaths: [URL] = modes.first?.targetFilePaths else { return }
    let queue = DispatchQueue.global(qos: .utility)
    let notificationCentre = NotificationCenter.default
    let notification = modes.contains(.default) ?
      Notification(name: .defaultIndexingDidFinish) : Notification(name: .documentIndexingDidFinish)
    queue.async { [unowned self] in
      for beginURL in targetPaths { self.addContent(in: beginURL, modes: modes) }
      notificationCentre.post(notification)
      if modes.contains(.default) {
       self.defaultFinished = true
      } else {
        self.documentFinished = true
      }
    }
  }
  
  /**
   The key function to recursively iterate through the file system structure and add files to index files
   - parameter path: the path to begin. This path and its children content (if path is a directory) will be added to the index files
   - parameter searchModes: the search modes are used to find the correct exclusion lists and correct index files
   */
  private func addContent(in path: URL, modes searchModes: SearchMode...) {
    addContent(in: path, modes: searchModes)
  }
  
  /**
   The key function to recursively iterate through the file system structure and add files to index files
   - parameter path: the path to begin. This path and its children content (if path is a directory) will be added to the index files
   - parameter searchModes: the search modes are used to find the correct exclusion lists and correct index files
   */
  private func addContent(in path: URL, modes searchModes: [SearchMode]) {
    for fileURL in PathIterator(beginURL: path, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
      try? add(fileURL: fileURL, searchModes: searchModes)
    }
  }
  
  /// Add fileURL to sepcific indices with specific search modes
  /// - parameter fileURL: the URL needs to be added
  /// - parameter searchModes: the search mode associated with the indexes
  /// - parameter indexes: the index candidates
  /// - throws: TonnerreIndexError.fileNotExist if file does not exist
  private func add(fileURL: URL, searchModes: [SearchMode]) throws {
    guard !shouldIgnore(path: fileURL) else { return }
    let indexes = searchModes.map { self.indexes[$0] }
    for (mode, index) in zip(searchModes, indexes) where mode.canInclude(fileURL: fileURL) {
      #if DEBUG
      let result = try index?.addDocument(atPath: fileURL, contentType: mode.contentType,
                                          additionalNote: getAlias(path: fileURL))
      print("\((result ?? false) ? "SUCCESS:" : "FAIL:")", fileURL)
      #else
      _ = try index?.addDocument(atPath: fileURL, contentType: mode.contentType,
                                 additionalNote: getAlias(path: fileURL))
      #endif
    }
  }
  
  /// Returns true if the given path should not be included in the index files
  private func shouldIgnore(path: URL) -> Bool {
    let pathPropertyIsNotAccepted: Bool
    do {
      let resource = try path.resourceValues(forKeys:
        [.isHiddenKey, .typeIdentifierKey, .isAliasFileKey, .isSymbolicLinkKey])
      let symbolicOrAlias = resource.isAliasFile == true || resource.isSymbolicLink == true
      let isDynamicFile = (resource.typeIdentifier ?? "").starts(with: "dyn")
      pathPropertyIsNotAccepted = symbolicOrAlias || isDynamicFile
    } catch { pathPropertyIsNotAccepted = false }
    let excludedBySystem = {
      FileTypeControl.isExcludedDir(url: path)
        || FileTypeControl.isExcludedURL(url: path) }
    return pathPropertyIsNotAccepted || excludedBySystem()
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
    guard
      !path.isHiddenDescendent(),
      !path.isPackageDescendent(),
      !shouldIgnore(path: path)
    else { return [] }
    let defaultDir = Set(SearchMode.default.targetFilePaths)
    if defaultDir.contains(path) { return [.default] }
    let documentDir = Set(SearchMode.name.targetFilePaths)
    let exclusions = FileTypeControl(types: .media, .image)
    let extensionAnalyze: (URL) -> [SearchMode] = { path in
      if path.hasDirectoryPath || exclusions.isInControl(file: path) { return [.name] }
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
    for (path, flags) in events {
      let pathURL = URL(fileURLWithPath: path)
      let relatedModes = identify(path: pathURL)
      guard !relatedModes.isEmpty else { return }
      let relatedIndexes = relatedModes.map { indexes[$0] }
      if flags.contains(.created) {
        for (mode, index) in zip(relatedModes, relatedIndexes)
          where mode.canInclude(fileURL: pathURL) {
          _ = try? index?.addDocument(atPath: pathURL,
                                      contentType: mode.contentType)
        }
      } else if flags.contains(.renamed) {
        let fileManager = FileManager.default
        for (mode, index) in zip(relatedModes, relatedIndexes)
          where mode.canInclude(fileURL: pathURL) {
          let exist = fileManager.fileExists(atPath: path)
          if exist == false {
            _ = index?.removeDocument(atPath: pathURL)
          } else {
            _ = try? index?.addDocument(atPath: pathURL,
                                        contentType: mode.contentType)
          }
        }
      } else if flags.contains(.removed) {
        for (mode, index) in zip(relatedModes, relatedIndexes)
          where mode.canInclude(fileURL: pathURL) {
          _ = index?.removeDocument(atPath: pathURL)
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
  private func getAlias(path: URL) -> String {
    let name = path.deletingPathExtension().lastPathComponent
    var alias = aliasDict[name, default: name.unicodeScalars.reduce("") {
      if CharacterSet.uppercaseLetters.contains($1) {
        if $0.isEmpty { return String($1) }
        else if CharacterSet.uppercaseLetters.contains($0.unicodeScalars.last!) {
          return $0 + String($1)
        } else {
          return $0 + " " + String($1)
        }
      } else {
        return $0 + String($1)
      }
    }]
    let extraAlias: (String) -> String = { origin in // Get initial of words, such as Activity Manager -> AM
      let elements = origin.components(separatedBy: " ").compactMap{ $0.first }.map{ String($0) }
      return " \(elements.joined())"
    }
    if alias.contains(" ") { alias += extraAlias(alias) }
    if name.contains(" ") { alias += extraAlias(name) }
    if alias == name { return "" }
    else { return alias }
  }
}
