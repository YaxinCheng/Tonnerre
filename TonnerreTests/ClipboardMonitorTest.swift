//
//  ClipboardMonitorTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-01-07.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class ClipboardMonitorTest: XCTestCase {
  
  var pasteboard: NSPasteboard!
  
  override func setUp() {
    pasteboard = NSPasteboard(name: .init("test"))
  }
  
  func testMonitoring() {
    let expectation = self.expectation(description: "monitored")
    let monitor = ClipboardMonitor(clipboard: pasteboard, interval: 1, repeat: true) { _,_  in
      expectation.fulfill()
    }
    monitor.start()
    pasteboard.clearContents()
    let setResult = pasteboard.setString("test", forType: .string)
    XCTAssert(setResult)
    pasteboard.clearContents()
    XCTAssert(pasteboard.setString("test2", forType: .string))
    waitForExpectations(timeout: 3, handler: nil)
  }
}
