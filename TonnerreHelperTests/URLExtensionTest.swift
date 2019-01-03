//
//  URLExtensionTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-01-02.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import TonnerreIndexHelper

class URLExtensionTest: XCTestCase {

  func testIsChild() {
    let parent = URL(fileURLWithPath: "/private")
    let child = URL(fileURLWithPath: "/private/tmp")
    XCTAssertTrue(child.isChildOf(url: parent))
  }
  
  func testIsHiddenDescendent() {
    let isHidden = URL(fileURLWithPath: "/private/tmp")
    XCTAssertTrue(isHidden.isHiddenDescendent())
  }
  
  func testIsNotHiddenDescendent() {
    let isNotHidden = URL(fileURLWithPath: NSHomeDirectory())
    XCTAssertFalse(isNotHidden.isHiddenDescendent())
  }
  
  func testIsNotPackageDescendent() {
    let safari = URL(fileURLWithPath: "/Applications/Safari.app")
    XCTAssertFalse(safari.isPackageDescendent())
  }
  
  func testIsPackageDescendent() {
    let safariInfoPlist = URL(fileURLWithPath: "/Applications/Safari.app/Contents/info.plist")
    XCTAssertTrue(safariInfoPlist.isPackageDescendent())
  }
}
