//
//  DefaultService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-23.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct DefaultService: TonnerreInterpreterService {
  static let keyword: String = "@default"
  let argLowerBound: Int = 0
  let argUpperBound: Int = Int.max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre")
  let itemIdentifier: NSUserInterfaceItemIdentifier = .OnOffCell
  
  func prepare(input: [String]) -> [Displayable] {
    let searchOptions: [DefaultSearchOption] = [.google, .bing, .duckDuckGo]
    let searchServices = searchOptions.map { $0.associatedService.init() }
    return searchServices
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard
      let service = source as? TonnerreService,
      let searchOption = DefaultSearchOption(rawValue: type(of: service).keyword)
    else { return }
    DefaultSearchOption.default = searchOption
  }
}
