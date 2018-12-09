//
//  MathInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct MathTokenizer {
  enum Token {
    case number(Double)
    case openBracket
    case closeBracket
    case unaryOp((Double)->Double)
    case binaryOpTop((Double, Double)->Double)
    case binaryOpHigh((Double, Double)->Double)
    case binaryOpLow((Double, Double)->Double)
  }
  
  private let numberPattern = "^(\\d+\\.)?\\d+|^(PI)|^π|^(pi)|^e"
  private let binaryOpTopPattern = "^(\\*\\*|\\^|%)"
  private let binaryOpHighPattern = "^[*/]"
  private let binaryOpLowPattern = "^[+\\-]"
  private let openBracketPattern = "^\\("
  private let closeBracketPattern = "^\\)"
  private let unaryOperatorPattern = "log2|log10|log|ln|sqrt|√|exp|cosh?|sinh?|tanh?|floor|ceil"
  
  private func match(string: String, regex: String, range: NSRange) -> (Substring, NSRange)? {
    let regularExp = try! NSRegularExpression(pattern: regex, options: .anchorsMatchLines)
    guard let matched = regularExp.firstMatch(in: string, options: .anchored, range: range) else { return nil }
    let matchedString = string[Range(matched.range, in: string)!]
    return (matchedString, matched.range)
  }
  
  private func binaryOperator(matchWith string: Substring) throws -> Token {
    let Operator: Token
    switch string {
    case "**", "^": Operator = .binaryOpTop(pow)
    case "*": Operator = .binaryOpHigh(*)
    case "/": Operator = .binaryOpHigh(/)
    case "%": Operator = .binaryOpTop(%)
    case "+": Operator = .binaryOpLow(+)
    case "-": Operator = .binaryOpLow(-)
    default: throw MathError.invalidToken(value: String(string))
    }
    return Operator
  }
  
  private func unaryOperator(matchWith string: Substring) throws -> Token {
    let Operator: Token
    switch string {
    case "ln", "log": Operator = .unaryOp(log)
    case "log10": Operator = .unaryOp(log10)
    case "log2": Operator = .unaryOp(log2)
    case "sqrt", "√": Operator = .unaryOp(sqrt)
    case "exp": Operator = .unaryOp(exp)
    case "cos": Operator = .unaryOp(cos)
    case "sin": Operator = .unaryOp(sin)
    case "tan": Operator = .unaryOp(tan)
    case "sinh": Operator = .unaryOp(sinh)
    case "cosh": Operator = .unaryOp(cosh)
    case "tanh": Operator = .unaryOp(tanh)
    case "floor": Operator = .unaryOp(floor)
    case "ceil": Operator = .unaryOp(ceil)
    default: throw MathError.invalidToken(value: String(string))
    }
    return Operator
  }
  
  func tokenize(expression: String) throws -> [Token] {
    let processingExp = expression.replacingOccurrences(of: " ", with: "")
    let patterns = [openBracketPattern, closeBracketPattern, unaryOperatorPattern, binaryOpTopPattern, binaryOpHighPattern, binaryOpLowPattern, numberPattern]
    var tokens: [Token] = []
    var index = processingExp.startIndex
    while index < processingExp.endIndex {
      var foundFlag = false
      for (patternNum, pattern) in patterns.enumerated() {
        let searchRange = NSRange(index..., in: processingExp)
        guard
          let (matchedString, matchedRange) = match(string: processingExp, regex: pattern, range: searchRange)
        else { continue }
        switch patternNum {
        case 0: tokens.append(.openBracket)
        case 1: tokens.append(.closeBracket)
        case 2: tokens.append(try unaryOperator(matchWith: matchedString))
        case 3...5: tokens.append(try binaryOperator(matchWith: matchedString))
        case 6: tokens.append(try constant(matchWith: matchedString))
        default: fatalError("Extra tokens")
        }
        index = processingExp.index(index, offsetBy: matchedRange.length)
        foundFlag = true
        break
      }
      if foundFlag == false { throw MathError.extraToken }
    }
    return tokens
  }
  
  private func constant(matchWith string: Substring) throws -> Token {
    let convertedConstant: Token
    switch string {
    case "PI", "π", "pi": convertedConstant = .number(.pi)
    case "e": convertedConstant = .number(exp(1))
    default:
      guard let number = Double(String(string)) else {
        throw MathError.invalidToken(value: String(string))
      }
      convertedConstant = .number(number)
    }
    return convertedConstant
  }
}

private extension Double {
  static func % (lhs: Double, rhs: Double) -> Double {
    return Double(Int(lhs) % Int(rhs))
  }
}
