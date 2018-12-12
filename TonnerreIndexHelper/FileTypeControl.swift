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
    let identifier = file.typeIdentifier as CFString
    for type in controlTypes {
      for uti in type.UTIs {
        if UTTypeConformsTo(identifier, uti) { return true }
      }
    }
    return false
  }
  
  private static func loadRawList() {
    let exclusionPath = Bundle.main.path(forResource: "exclusionList", ofType: "plist")!
    self.rawList = NSDictionary(contentsOfFile: exclusionPath) as! [String: [String]]
  }
  
  static func isExcludedURL(url: URL) -> Bool {
    if self.rawList.isEmpty { loadRawList() }
    let control = self.rawList["path"] ?? []
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    let exclusionURL = Set(control.map( homeDir.appendingPathComponent ))
    if exclusionURL.contains(url) { return true }
    for exURL in exclusionURL {
      if url.isChildOf(url: exURL) { return true }
    }
    return isInPackageOrHideFolder(url: url)
  }
  
  static private func isInPackageOrHideFolder(url: URL) -> Bool {
    let urlComponents = url.deletingLastPathComponent().pathComponents
    var basePath = URL(fileURLWithPath: "/")
    for component in urlComponents {
      basePath.appendPathComponent(component)
      let componentIsHiden = component.starts(with: ".")
      let componentIsPackage = component.contains(".")
      if componentIsHiden { return true }
      if !componentIsPackage { continue }
      do {
        return try basePath.resourceValues(forKeys: [.isPackageKey]).isPackage ?? false
      } catch { continue }
    }
    return false
  }
  
  static func isExcludedDir(url: URL) -> Bool {
    if self.rawList.isEmpty { loadRawList() }
    let control = Set(self.rawList["directory"] ?? [])
    return control.contains(url.lastPathComponent.lowercased())
  }
}
