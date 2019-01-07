//
//  TaggedListTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2018-12-21.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class TaggedListTest: XCTestCase {
  
  var list: TaggedList<String>!
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    list = ["Canada", "China", "Czech"]
  }
  
  func testGetValue() {
    XCTAssertEqual(list[0], "Canada")
    XCTAssertEqual(list[1], "China")
    XCTAssertEqual(list[2], "Czech")
  }

  func testAppendWithExisting() {
    let originalCount = list.count
    let insertValues = ["US", "Mexico"]
    list.append(at: "Canada", elements: insertValues)
    XCTAssertEqual(list.count, originalCount + insertValues.count)
    XCTAssertEqual(list[0], "Canada")
    XCTAssertEqual(list[1], "US")
    XCTAssertEqual(list[2], "Mexico")
  }
  
  func testAppendWithoutExisting() {
    let originalCount = list.count
    let insertValues = ["Ecuador", "Argentina"]
    list.append(at: "Columbia", elements: insertValues)
    XCTAssertEqual(list.count, originalCount + insertValues.count + 1)
    XCTAssertEqual(list[3], "Columbia")
    XCTAssertEqual(list[4], "Ecuador")
    XCTAssertEqual(list[5], "Argentina")
  }
  
  func testReplaceWithExisting() {
    list.replace(at: "Canada", elements: ["Columbia"])
    XCTAssertEqual(list[0], "Columbia")
  }
  
  func testReplaceWithoutExisting() {
    let originalCount = list.count
    list.replace(at: "Columbia", elements: ["Cambodia"])
    XCTAssertEqual(list.count, originalCount + 1)
    XCTAssertEqual(list[originalCount], "Cambodia")
  }
  
  func testSkipEmpty() {
    let originalCount = list.count
    list.replace(at: "China", elements: [])
    XCTAssertEqual(list.count, originalCount - 1)
    XCTAssertEqual(list[1], "Czech")
  }
  
  func testIterateWithEmpty() {
    list.replace(at: "China", elements: [])
    for (index, value) in list.enumerated() {
      if index == 0 { XCTAssertEqual(value, "Canada") }
      else if index == 1 { XCTAssertEqual(value, "Czech") }
    }
  }
  
  func testListChangeCallback() {
    final class delegateTest: TaggedListDelegate {
      var expectedIndex: Int!
      
      func listDidChange(from index: Int) {
        XCTAssertEqual(expectedIndex, index)
      }
    }
    
    let tester = delegateTest()
    list.delegate = tester
    tester.expectedIndex = 1
    list.append(at: "China", elements: ["Vietnam"])
    tester.expectedIndex = 0
    list.append(at: "Canada", elements: ["Mexico"])
    tester.expectedIndex = 2
    list.append(at: "China", elements: ["Laos"])
  }
}
