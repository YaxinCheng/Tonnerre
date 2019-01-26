//
//  SupportFolders.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-01-22.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

/// This enum interacts with the folders that stores configurations, services, and cache
/// in `~/Library/Application Support`
enum SupportFolders: String {
  
  /// `~/Library/Application Support`
  case base     = ""
  /// `~/Library/Application Support/Indices`
  case indices  = "Indices"
  /// `~/Library/Application Support/Services`
  case services = "Services"
  /// `~/Library/Application Support/Cache`
  case cache    = "Cache"
  
  private var supportPath: URL {
    let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let folderName = "Tonnerre"
    return appSupportPath.appendingPathComponent(folderName)
  }
  
  /// Get the URL typed path to the folder
  var path: URL {
    switch self {
    case .base: return supportPath
    default: return supportPath.appendingPathComponent(rawValue)
    }
  }
  
  /// Returns true if the folder exists
  var exists: Bool {
    return FileManager.default.fileExists(atPath: path.path)
  }
  
  /// Creates the folder if not exists
  /// - throws: if the folder cannot be created
  func create() throws {
    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false)
  }
}
