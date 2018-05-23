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
    let control = ExclusionControl(type: .path)
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    let exclusionURL = Set(control.exclusionSet.map( homeDir.appendingPathComponent ))
    if exclusionURL.contains(url) { return true }
    for each in exclusionURL {
      if url.isChildOf(url: each) { return true }
    }
    return false
  }
  
  static func isExcludedDir(name: String) -> Bool {
    let control = ExclusionControl(type: .directory)
    if control.exclusionSet.contains(name) { return true }
    for each in control.exclusionSet {
      if name.hasSuffix(each) { return true }
    }
    return false
  }
}
