//
//  TonnerreInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-29.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreInterpreter {
  private func tokenize(rawCmd: String) -> [String] {
    return rawCmd.components(separatedBy: .whitespaces)
  }
  
  
}
