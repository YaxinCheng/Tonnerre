//
//  SettingSubscriberTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-02-26.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class SettingSubscriberTest: XCTestCase {
  
  static let testSubscribedKey: SettingKey = .warnBeforeExit
  
  private class mockSubscriber: SettingSubscriber {
    let subscribedKey: SettingKey = SettingSubscriberTest.testSubscribedKey
    var count = 0
    
    func settingDidChange() {
      switch TonnerreSettings.get(fromKey: SettingSubscriberTest.testSubscribedKey) {
      case .string(let value)?:
        XCTAssertEqual(value, "value")
        SettingSubscriberTest.expect.fulfill()
      case .bool(let value)?:
        XCTAssertEqual(value, SettingSubscriberTest.originalValue!.rawValue as! Bool)
      default: XCTFail("Wrong notification")
      }
    }
  }
  
  static var originalValue: SettingValue! = nil
  var observer: SettingObserver!
  private var subscriber = mockSubscriber()
  static var expect: XCTestExpectation!
  
  override func setUp() {
    SettingSubscriberTest.originalValue = TonnerreSettings.get(fromKey: SettingSubscriberTest.testSubscribedKey)
    
    observer = SettingObserver()
    observer.register(subscriber: subscriber)
    SettingSubscriberTest.expect = expectation(description: "Expectation")
  }
  
  override func tearDown() {
    observer = nil
    TonnerreSettings.set(SettingSubscriberTest.originalValue, forKey: SettingSubscriberTest.testSubscribedKey)
  }
  
  func testObserve() {
    TonnerreSettings.set("value", forKey: SettingSubscriberTest.testSubscribedKey)
    wait(for: [SettingSubscriberTest.expect], timeout: 2)
  }
  
}
