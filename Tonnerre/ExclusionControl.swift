//
//  ExclusionControl.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct ExclusionControl {
  
  enum ExclusionType: String {
    case media
    case coding
    case path
    case directory
  }
  
  private(set) static var rawList: [String: [String]] = [:]
  let exclusionSet: Set<String>
  
  init(type: ExclusionType) {
    self.init(types: [type])
  }
  
  init(types: ExclusionType...) {
    self.init(types: types)
  }
  
  init(types: [ExclusionType]) {
    if ExclusionControl.rawList.isEmpty {
      let exclusionPath = Bundle.main.path(forResource: "exclusionList", ofType: "plist")!
      ExclusionControl.rawList = NSDictionary(contentsOfFile: exclusionPath) as! [String: [String]]
    }
    exclusionSet = Set(types.compactMap({ ExclusionControl.rawList[$0.rawValue] }).reduce([], +))
  }
  
  func contains(_ element: String) -> Bool {
    return exclusionSet.contains(element)
  }
  
  static func isExcludedURL(url: URL) -> Bool {
    if ExclusionControl.rawList.isEmpty {
      let exclusionPath = Bundle.main.path(forResource: "exclusionList", ofType: "plist")!
      ExclusionControl.rawList = NSDictionary(contentsOfFile: exclusionPath) as! [String: [String]]
    }
    let currentUserDir = FileManager.default.homeDirectoryForCurrentUser
    let excludedURL = Set(ExclusionControl.rawList["path"]!.map({ currentUserDir.appendingPathComponent($0) }))
    if excludedURL.contains(url) { return true }
    for each in excludedURL {
      if url.isChildOf(url: each) { return true }
    }
    return false
  }
}
