//
//  StringExtensionTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2018-12-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class StringExtensionTest: XCTestCase {

  func testFilledWithEqualArgs() {
    let template = "%@=%@"
    XCTAssertEqual(template.filled(arguments: ["Key", "Value"]), "Key=Value")
  }
  
  func testFilledWithMoreArgs() {
    let template = "%@=%@"
    XCTAssertEqual(template.filled(arguments: ["Key", "Value", "1"]), "Key=Value 1")
  }
  
  func testFilledWithMoreArgsPlusSeparator() {
    let template = "%@=%@"
    XCTAssertEqual(template.filled(arguments: ["Key", "Value", "1"], separator: "+"), "Key=Value+1")
  }

  func testFilledWithLessArgs() {
    let template = "%@=%@"
    XCTAssertEqual(template.filled(arguments: ["Key"]), template)
  }
  
  func testTruncatedLeadingSpaces() {
    let leadingSpaces = "      string"
    XCTAssertEqual(leadingSpaces.truncatedSpaces, "string")
  }
  
  func testTruncatedTrailingSpaces() {
    let trailingSpaces = "string    "
    XCTAssertEqual(trailingSpaces.truncatedSpaces, "string ")
  }
  
  func testTruncatedTrailingSpace() {
    let trailingSpace = "string "
    XCTAssertEqual(trailingSpace.truncatedSpaces, trailingSpace)
  }
  
  func testTruncatedLeadingAndTrailingSpaces() {
    let mixString = "    string    "
    XCTAssertEqual(mixString.truncatedSpaces, "string ")
  }
}
