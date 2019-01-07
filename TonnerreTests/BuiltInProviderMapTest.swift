//
//  BuiltInProviderMapTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-01-07.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class BuiltInProviderMapTest: XCTestCase {
  
  func testExtractKeyword() {
    let keyword = BuiltInProviderMap.extractKeyword(from: GoogleSearch.self)
    XCTAssertEqual(keyword, "google")
  }
  
  func testExtractEmptyKeyword() {
    let keyword = BuiltInProviderMap.extractKeyword(from: LaunchService.self)
    XCTAssertTrue(keyword.isEmpty)
  }
  
  func testTypeRetrieve() {
    let type = BuiltInProviderMap.retrieveType(baseOnID: "Tonnerre.Provider.BuiltIn.GoogleSearch")
    XCTAssertNotNil(type)
    XCTAssertEqual("\(GoogleSearch.self)", "\(type!)")
  }
  
}
