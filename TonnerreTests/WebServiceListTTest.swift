//
//  WebServiceListTTest.swift
//  TonnerreTests
//
//  Created by Yaxin Cheng on 2019-03-29.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import XCTest
@testable import Tonnerre

class WebServiceListTTest: XCTestCase {
  
  func testGetExistingSuggestion() {
    let google = GoogleImageSearch()
    let webServicesList = WebServiceList.shared
    let template = webServicesList[google, .suggestionsTemplate]
    XCTAssertNotEqual(template, "")
    XCTAssertEqual(template, "https://suggestqueries.google.com/complete/search?client=safari&q=%@")
  }
  
  func testGetExistingTemplate() {
    let google = GoogleImageSearch()
    let webServiceList = WebServiceList.shared
    let template = webServiceList[google, .serviceTemplate]
    XCTAssertNotEqual(template, "")
    XCTAssertEqual(template, "https://google.ca/search?q=%@&tbm=isch")
  }
  
}
