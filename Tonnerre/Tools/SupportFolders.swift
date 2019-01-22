//
//  SupportFolders.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-01-22.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

enum SupportFolders: String {
  
  case base     = ""
  case indices  = "Indices"
  case services = "Services"
  case cache    = "Cache"
  
  private var supportPath: URL {
    let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let folderName = "Tonnerre"
    return appSupportPath.appendingPathComponent(folderName)
  }
  
  var path: URL {
    switch self {
    case .base: return supportPath
    default: return supportPath.appendingPathComponent(rawValue)
    }
  }
  
  var exists: Bool {
    return FileManager.default.fileExists(atPath: path.path)
  }
  
  func create() throws {
    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false)
  }
}
