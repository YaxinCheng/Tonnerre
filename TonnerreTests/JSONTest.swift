//
//  JSONTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2018-12-21.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class JSONTest: XCTestCase {
  
  let testFolder = NSHomeDirectory() + "/testFolder"
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    let jsonString = """
{"level1": "valueLevel1", "level2": {"keyLevel2": "valueLevel2"}, "array": [1, 2, 3]}
"""
    let jsonData = jsonString.data(using: .utf8)
    try! FileManager.default.createDirectory(atPath: testFolder, withIntermediateDirectories: true, attributes: nil)
    FileManager.default.createFile(atPath: testFolder + "/test.json", contents: jsonData, attributes: nil)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    try! FileManager.default.removeItem(at: URL(fileURLWithPath: testFolder + "/test.json"))
    try! FileManager.default.removeItem(at: URL(fileURLWithPath: testFolder))
  }
  
  func testConstructByData() {
    let jsonData = try! Data(contentsOf: URL(fileURLWithPath: testFolder + "/test.json"))
    let json = JSON(data: jsonData)
    XCTAssertNotNil(json)
  }
  
  func testConstructByArray() {
    let arrayJson: [Any] = [1, 2, 3, 4, ["key": "value"]]
    let json = JSON(array: arrayJson)
    XCTAssertNotNil(json)
  }
  
  func testConstructByDictionary() {
    let dictionaryJson: [String: Any] = ["key": "value", "key2": 1, "key3": [1, 2, 3]]
    let json = JSON(dictionary: dictionaryJson)
    XCTAssertNotNil(json)
  }
  
  func testConstructByArrayLiteral() {
    let json: JSON = [1, 2, 3, 4, ["key": "value"]]
    XCTAssertNotNil(json)
  }
  
  func testConstructByDictionaryLiteral() {
    let json: JSON = ["key": "value", "key2": 1, "key3": [1, 2, 3]]
    XCTAssertNotNil(json)
  }
  
  func testGetValue() {
    let jsonData = try! Data(contentsOf: URL(fileURLWithPath: testFolder + "/test.json"))
    let json = JSON(data: jsonData)
    XCTAssertNotNil(json)
    XCTAssertEqual(json!["level1"] as! String, "valueLevel1")
    XCTAssertEqual(json!["level2", "keyLevel2"] as! String, "valueLevel2")
    XCTAssertEqual(json!["array", 1] as! Int, 2)
  }
}

