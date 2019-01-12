//
//  PathIterator.swift
//  TonnerreIndexHelper
//
//  Created by Yaxin Cheng on 2019-01-02.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct PathIterator: Sequence {
  let beginURL: URL
  let options: Options
  typealias Options = FileManager.DirectoryEnumerationOptions
  
  init(beginURL: URL, options: Options = []) {
    self.beginURL = beginURL
    self.options = options
  }
  
  func makeIterator() -> PathIterator.Iterator {
    return Iterator(beginURL: beginURL, options: options)
  }
}

extension PathIterator {
  struct Iterator: IteratorProtocol {
    let beginURL: URL
    let options: Options
    private var firstCall: Bool = true
    private lazy var enumerator: FileManager.DirectoryEnumerator? = {
      let resource = try? beginURL.resourceValues(forKeys: [.isPackageKey])
      if resource?.isPackage == true && options.contains(.skipsPackageDescendants) { return nil }
      return FileManager.default.enumerator(at: beginURL,
                                            includingPropertiesForKeys: [.isAliasFileKey, .isSymbolicLinkKey],
                                            options: options)
    }()
    
    init(beginURL: URL, options: Options) {
      self.beginURL = beginURL
      self.options = options
    }
    
    mutating func next() -> URL? {
      if firstCall {
        firstCall = false
        return beginURL
      }
      return enumerator?.nextObject() as? URL
    }
  }
}
