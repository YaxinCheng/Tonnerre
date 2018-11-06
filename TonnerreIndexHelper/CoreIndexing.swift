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
    let pathes: [String] = [SearchMode.default.targetFilePaths, SearchMode.name.targetFilePaths].reduce([], +).map({$0.path})
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
    let lostIndexes = allModes.filter { !fileManager.fileExists(atPath: $0.indexFileURL.path) }
    return lostIndexes
  }
  
  var defaultFinished: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: .defaultInxFinished)
      if newValue == true && documentFinished {
        detector.start()
      }
    } get {
      return UserDefaults.standard.bool(forKey: .defaultInxFinished)
    }
  }
  
  var documentFinished: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: .documentInxFinished)
      if newValue == true && defaultFinished {
        detector.start()
      }
    } get {
      return UserDefaults.standard.bool(forKey: .documentInxFinished)
    }
  }
  
  func check() {
    let lostIndexes = lostIndeces()
    if defaultFinished == false || lostIndexes.contains(.default) {
      defaultFinished = false
      fullIndex(modes: .default)
    }
    if documentFinished == false || lostIndexes.contains(.name) || lostIndexes.contains(.content) {
      if lostIndexes.contains(.content) && lostIndexes.contains(.name) {
        fullIndex(modes: .name, .content)
      } else if lostIndexes.contains(.name) {
        fullIndex(modes: .name)
      } else if lostIndexes.contains(.content) {
        fullIndex(modes: .content)
      } else {
        fullIndex(modes: .name, .content)
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
    let beginNotification = modes.contains(.default) ? Notification(name: .defaultIndexingDidBegin) : Notification(name: .documentIndexingDidBegin)
    let endNotification = modes.contains(.default) ? Notification(name: .defaultIndexingDidFinish) : Notification(name: .documentIndexingDidFinish)
    queue.async { [unowned self] in
      notificationCentre.post(beginNotification)
      let indeces = modes.compactMap({ self.indexes[$0, true] })
      for beginURL in targetPaths { self.addContent(in: beginURL, modes: modes, indexes: indeces) }
      notificationCentre.post(endNotification)
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
  private func addContent(in path: URL, modes searchModes: SearchMode..., indexes: [TonnerreIndex]) {
    addContent(in: path, modes: searchModes, indexes: indexes)
  }
  
  /**
   The key function to recursively iterate through the file system structure and add files to index files
   - parameter path: the path to begin. This path and its children content (if path is a directory) will be added to the index files
   - parameter searchModes: the search modes are used to find the correct exclusion lists and correct index files
   */
  private func addContent(in path: URL, modes searchModes: [SearchMode], indexes: [TonnerreIndex]) {
    if path.isSymlink || path.typeIdentifier.starts(with: "dyn") { return }
    for (mode, index) in zip(searchModes, indexes) where mode.canInclude(fileURL: path) {
      _ = try? index.addDocument(atPath: path, additionalNote: getAlias(path: path))
    }
    // Prevent FileManager from indexing what's inside apps
    let isPackage = (try? path.resourceValues(forKeys: [.isPackageKey]))?.isPackage ?? false
    guard
      !isPackage,
      let enumerator = FileManager.default.enumerator(at: path, includingPropertiesForKeys: [.isAliasFileKey, .isSymbolicLinkKey, .typeIdentifierKey], options: [.skipsHiddenFiles, .skipsPackageDescendants], errorHandler: nil)
    else { return }
    for case let fileURL as URL in enumerator {
      for (mode, index) in zip(searchModes, indexes) {
        guard
          mode.canInclude(fileURL: fileURL),
          !fileURL.typeIdentifier.starts(with: "dyn"),
          !FileTypeControl.isExcludedURL(url: fileURL),
          !FileTypeControl.isExcludedDir(url: fileURL)
        else { continue }
        _ = try? index.addDocument(atPath: fileURL, additionalNote: self.getAlias(path: fileURL))
        #if DEBUG
        print(fileURL)
        #endif
      }
    }
  }
  
  @objc private func defaultIndexingDidFinish() {
    UserDefaults.standard.set(true, forKey: .defaultInxFinished)
  }
  
  @objc private func documentIndexingDidFinish() {
    UserDefaults.standard.set(true, forKey: .documentInxFinished)
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
    let defaultDir = Set(SearchMode.default.targetFilePaths)
    if defaultDir.contains(path) { return [.default] }
    let documentDir = Set(SearchMode.name.targetFilePaths)
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
    for (path, flags) in events {
      let pathURL = URL(fileURLWithPath: path)
      let relatedModes = identify(path: pathURL)
      let relatedIndexes = relatedModes.map { indexes[$0, true] }
      if flags.contains(.created) {
        for (mode, index) in zip(relatedModes, relatedIndexes)
          where mode.canInclude(fileURL: pathURL) {
          _ = try? index.addDocument(atPath: pathURL)
        }
      } else if flags.contains(.renamed) {
        let fileManager = FileManager.default
        for (mode, index) in zip(relatedModes, relatedIndexes)
          where mode.canInclude(fileURL: pathURL) {
          let exist = fileManager.fileExists(atPath: path)
          if exist == false {
            _ = index.removeDocument(atPath: pathURL)
          } else {
            _ = try? index.addDocument(atPath: pathURL)
          }
        }
      } else if flags.contains(.removed) {
        for (mode, index) in zip(relatedModes, relatedIndexes)
          where mode.canInclude(fileURL: pathURL) {
          _ = index.removeDocument(atPath: pathURL)
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
