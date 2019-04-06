//
//  FileTypeControl.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreServices

struct FileTypeControl {
  enum ControlType {
    case document
    case media
    case image
    case app
    case systemPref
    case message
    case diskImage
    
    var UTIs: [CFString] {
      switch self {
      case .document: return [kUTTypeText, kUTTypeCompositeContent]
      case .media: return [kUTTypeAudiovisualContent]
      case .image: return [kUTTypeImage]
      case .app: return [kUTTypeApplication]
      case .systemPref: return ["com.apple.systempreference.prefpane" as CFString]
      case .message: return [kUTTypeMessage]
      case .diskImage: return [kUTTypeDiskImage]
      }
    }
  }
  
  private let controlTypes: [FileTypeControl.ControlType]
  private static var rawList: [String: [String]] = [:]
  
  init(type: FileTypeControl.ControlType) {
    controlTypes = [type]
  }
  
  init(types: FileTypeControl.ControlType...) {
    controlTypes = types
  }
  
  func isInControl(file: URL) -> Bool {
    do {
      let resource = try file.resourceValues(forKeys: [.typeIdentifierKey])
      guard
        let typeID = resource.typeIdentifier
      else { return false }
      let identifier = typeID as CFString
      for type in controlTypes {
        for uti in type.UTIs {
          if UTTypeConformsTo(identifier, uti) { return true }
        }
      }
    } catch {
      #if DEBUG
      print("isInControl: Unable to get URL Resource: \(file)")
      #endif
    }
    return false
  }
  
  private static func loadRawList() {
    let content: Result<[String: [String]], Error> = PropertyListSerialization.read(fileName: "exclusionList")
    switch content {
    case .success(let rawList): self.rawList = rawList
    case .failure(let error):
      #if DEBUG
      print("Load raw list failed", error)
      #endif
    }
  }
  
  static func isExcludedURL(url: URL) -> Bool {
    if self.rawList.isEmpty { loadRawList() }
    let control = self.rawList["path"] ?? []
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    let (withoutTilde, withTilde) = control.reduce(([], [])) {
    (result, urlStr) -> ([String], [String]) in
      if urlStr.starts(with: "~/") {
        return (result.0, result.1 + [urlStr])
      } else {
        return (result.0 + [urlStr], result.1)
      }
    }
    let expandedTildeURLs = withTilde
            .map { String($0.dropFirst(2)) }
            .map(homeDir.appendingPathComponent)
    let exclusionURL = Set(withoutTilde.map { URL(fileURLWithPath: $0) }
                          + expandedTildeURLs)
    if exclusionURL.contains(url) { return true }
    for exURL in exclusionURL {
      if url.isChildOf(url: exURL) { return true }
    }
    return false
  }
  
  static func hasExcludedDirName(url: URL) -> Bool {
    if self.rawList.isEmpty { loadRawList() }
    let control = Set(self.rawList["directory"] ?? [])
    for component in url.pathComponents {
      if control.contains(component) { return true }
    }
    return false
  }
}
