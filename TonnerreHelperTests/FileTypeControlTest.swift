//
//  FileTypeControlTest.swift
//  TonnerreHelperTests
//
//  Created by Yaxin Cheng on 2019-01-14.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import TonnerreIndexHelper

class FileTypeControlTest: XCTestCase {
  
  func testIsExcludedURL() {
    let musicURL = URL(fileURLWithPath: NSHomeDirectory() + "/Music/iTunes/Album Artwork")
    let shouldBeTrue = FileTypeControl.isExcludedURL(url: musicURL)
    XCTAssertTrue(shouldBeTrue)
  }
  
  func testIsNotExcludedURL() {
    let musicURL = URL(fileURLWithPath: NSHomeDirectory() + "/Music/iTunes")
    let shoulBeFalse = FileTypeControl.isExcludedURL(url: musicURL)
    XCTAssertFalse(shoulBeFalse)
  }
  
  func testIsExcludedDir() {
    let excludedDirNames = ["bin", "venv", "lib", "locale", "locales", "log", "logs", "cache", "__pycache__"]
    for name in excludedDirNames {
      let url = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/\(name)")
      let shouldBeTrue = FileTypeControl.hasExcludedDirName(url: url)
      XCTAssertTrue(shouldBeTrue)
    }
  }
  
  func testIsExcludedDirDescendants() {
    let excludedDirNames = ["bin", "venv", "lib", "locale", "locales", "log", "logs", "cache", "__pycache__"]
    for name in excludedDirNames {
      let url = URL(fileURLWithPath: "\(NSHomeDirectory())/Documents/\(name)/anyPath/Another/Level")
      let shouldBeTrue = FileTypeControl.hasExcludedDirName(url: url)
      XCTAssertTrue(shouldBeTrue)
    }
  }
}
