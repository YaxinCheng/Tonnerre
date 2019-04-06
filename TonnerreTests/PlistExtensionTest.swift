//
//  PlistExtensionTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-04-05.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest

class PlistExtensionTest: XCTestCase {
  func testReadSuccessWithName() {
    let content: Result<[String:String], Error> = PropertyListSerialization.read(fileName: "browsers")
    switch content {
    case .success(let info):
      XCTAssertEqual(info["Safari"], "com.apple.safari")
    case .failure(let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReadSuccessWithURL() {
    let path = Bundle.main.url(forResource: "browsers", withExtension: "plist")!
    let content: Result<[String:String], Error> = PropertyListSerialization.read(path)
    switch content {
    case .success(let info):
      XCTAssertEqual(info["Safari"], "com.apple.safari")
    case .failure(let error):
      XCTFail(error.localizedDescription)
    }
  }
  
  func testReadFail() {
    let content: Result<[String:String], Error> = PropertyListSerialization.read(fileName: "notExist")
    if case .success(_) = content { XCTFail("Read non exist file") }
  }
}
