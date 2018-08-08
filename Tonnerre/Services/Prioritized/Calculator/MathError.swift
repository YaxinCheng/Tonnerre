//
//  MathError.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum MathError: Error {
  case invalidToken(value: String)
  case extraToken
  case unclosedBracket // has open bracket but not closed
  case missingBracket// function is not followed by a bracket
  case zeroDivision
}
