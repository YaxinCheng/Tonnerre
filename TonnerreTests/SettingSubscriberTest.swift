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
    
    func settingDidChange(_ changes: [NSKeyValueChangeKey : Any]) {
      XCTAssertTrue(changes[.newKey] is String && changes[.kindKey] is Bool)
    }
  }
  
  var originalValue: SettingValue! = nil
  var observer: SettingObserver!
  private var subscriber = mockSubscriber()
  
  override func setUp() {
    originalValue = TonnerreSettings.get(fromKey: SettingSubscriberTest.testSubscribedKey)
    
    observer = SettingObserver()
    observer.register(subscriber: subscriber)
  }
  
  override func tearDown() {
    observer = nil
    TonnerreSettings.set(originalValue, forKey: SettingSubscriberTest.testSubscribedKey)
  }
  
  func testObserve() {
    TonnerreSettings.set("value", forKey: SettingSubscriberTest.testSubscribedKey)
  }
  
}
