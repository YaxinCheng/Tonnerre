//
//  URL+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension URL {
  /**
   /Users/cheng/Documents is a child of /Users and /Users/cheng
  */
  func isChildOf(url: URL) -> Bool {
    guard self.path.count > url.path.count else { return false }
    let selfComponents = self.pathComponents
    let otherComponents = url.pathComponents
    return zip(selfComponents, otherComponents).map(==).reduce(true, { $0 && $1 })
  }
  
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
