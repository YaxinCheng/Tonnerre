//
//  URLExtensionTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-01-02.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class URLExtensionTest: XCTestCase {

  func testIsChild() {
    let parent = URL(fileURLWithPath: "/private")
    let child = URL(fileURLWithPath: "/private/tmp")
    XCTAssertTrue(child.isChildOf(url: parent))
  }
  
}
