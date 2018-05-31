//
//  TonnerreInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreInterpreter {
  private static var loader = TonnerreServiceLoader()
  
  private func tokenize(rawCmd: String) -> [String] {
    return rawCmd.components(separatedBy: .whitespaces)
  }
  
  private func parse(tokens: [String]) -> [TonnerreService] {
    if tokens.count == 1 {
      return TonnerreInterpreter.loader.autoComplete(key: tokens.first!) + [LaunchService()]
    } else {
      return TonnerreInterpreter.loader.exactMatch(key: tokens.first!)
    }
  }
  
  func interpret(rawCmd: String) -> [Displayable] {
    guard !rawCmd.isEmpty else { return [] }
    let tokens = tokenize(rawCmd: rawCmd)
    let services = parse(tokens: tokens)
    return services.map ({
      let keywordCount = ($0.keyword != "").hashValue
      let filteredTokens = tokens.filter({ !$0.isEmpty })
      if filteredTokens.count >= keywordCount + $0.arguments.count {
        return $0.process(input: Array(filteredTokens[keywordCount...]))
      } else {
        return [$0]
      }
    }).reduce([], +)
  }
}
