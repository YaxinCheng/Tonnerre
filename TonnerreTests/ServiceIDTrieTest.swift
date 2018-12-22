//
//  ServiceIDTrieTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2018-12-21.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class ServiceIDTrieTest: XCTestCase {
  
  var trie: ServiceIDTrie!
  
  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    trie = ServiceIDTrie(array: [("Tonnerre", "Thunder"),
                                 ("Bonjour", "Hello"),
                                 ("Ton", "Your")])
  }
  
  func testFindNotExit() {
    let onlyWildCard = trie.find(basedOn: "random")
    XCTAssertEqual(onlyWildCard.count, 0)
  }
  
  func testFindWithCommonPrefix() {
    let commonPrefixOfTon = trie.find(basedOn: "Ton")
    XCTAssertEqual(commonPrefixOfTon.count, 2)
    XCTAssertTrue(commonPrefixOfTon.contains("Thunder"))
    XCTAssertTrue(commonPrefixOfTon.contains("Your"))
  }
  
  func testInsert() {
    let onlyOneBeforeInsertion = trie.find(basedOn: "Bon")
    XCTAssertEqual(onlyOneBeforeInsertion.count, 1)
    trie.insert(value: "Good", key: "Bon")
    let twoAfterInsertion = trie.find(basedOn: "Bon")
    XCTAssertEqual(twoAfterInsertion.count, 2)
  }
  
  func testRemove() {
    let twoBeforeRemoving = trie.find(basedOn: "Ton")
    XCTAssertEqual(twoBeforeRemoving.count, 2)
    trie.remove(value: "Your", key: "Ton")
    let oneAfterRemoving = trie.find(basedOn: "Ton")
    XCTAssertEqual(oneAfterRemoving.count, 1)
    XCTAssertEqual(oneAfterRemoving[0], "Thunder")
  }
}
