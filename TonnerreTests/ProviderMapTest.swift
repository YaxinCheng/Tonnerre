//
//  ProviderMapTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-01-07.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class ProviderMapTest: XCTestCase {
  
  fileprivate struct DummyProvider: ServiceProvider {
    let id: String
    
    let keyword: String = ""
    let argLowerBound: Int = 0
    let argUpperBound: Int = 0
    func prepare(withInput input: [String]) -> [DisplayProtocol] {
      return []
    }
    func serve(service: DisplayProtocol, withCmd: Bool) {
    }
    let icon = NSImage()
    let placeholder: String = ""
  }
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    ProviderMap.shared.stop()
  }
  
  func testRetrieveFromBuiltInMap() {
    let googleID = "Tonnerre.Provider.BuiltIn.GoogleSearch"
    let google = ProviderMap.shared.retrieve(byID: googleID)
    XCTAssertNotNil(google)
    XCTAssertEqual(google!.id, googleID)
  }
  
  func testRegister() {
    let id = "Does.Not.Exist"
    let shouldBeNil = ProviderMap.shared.retrieve(byID: id)
    XCTAssertNil(shouldBeNil)
    try! ProviderMap.shared.register(provider: DummyProvider(id: id))
    let shouldExistNow = ProviderMap.shared.retrieve(byID: id)
    XCTAssertNotNil(shouldExistNow)
    XCTAssertEqual(shouldExistNow!.id, id)
  }
  
  func testUnregister() {
    let id = "Desired.ID"
    let shouldBeNil = ProviderMap.shared.retrieve(byID: id)
    XCTAssertNil(shouldBeNil)
    try! ProviderMap.shared.register(provider: DummyProvider(id: id))
    let shouldExistNow = ProviderMap.shared.retrieve(byID: id)
    XCTAssertNotNil(shouldExistNow)
    XCTAssertEqual(shouldExistNow!.id, id)
    ProviderMap.shared.unregister(provider: DummyProvider(id: id))
    let shouldBeNilAgain = ProviderMap.shared.retrieve(byID: id)
    XCTAssertNil(shouldBeNilAgain)
  }
  
  func testDuplicateRegister() {
    let id = "Duplicated.ID"
    try! ProviderMap.shared.register(provider: DummyProvider(id: id))
    do {
      try ProviderMap.shared.register(provider: DummyProvider(id: id))
      XCTFail("Error should be threw for duplicated ids")
    } catch {
      XCTAssertEqual("\(error.self)", "idExists(id: \"Duplicated.ID\")")
    }
  }
}
