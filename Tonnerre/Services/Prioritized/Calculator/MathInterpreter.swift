//
//  MathInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct MathInterpreter {
  enum Token {
    case number(Decimal)
    case openBracket
    case closeBracket
    case binaryOp((Decimal, Decimal)->Decimal, Int)
    case unaryOp((Decimal)->Decimal)
  }
  
  private let numberPattern = "^(\\d*\\.\\d+)|^(\\d+)|^(PI)|^π|^(pi)"
  private let binaryOperatorPattern = "^\\*\\*|[+\\-*/%^]"
  private let openBracketPattern = "^\\("
  private let closeBracketPattern = "^\\)"
  private let unaryOperatorPattern = "log|ln|sqrt|√|exp"
  
  private func match(string: String, regex: String, range: NSRange) -> (Substring, NSRange)? {
    let regularExp = try! NSRegularExpression(pattern: regex, options: .anchorsMatchLines)
    guard let matched = regularExp.firstMatch(in: string, options: .anchored, range: range) else { return nil }
    let matchedString = string[Range(matched.range, in: string)!]
    return (matchedString, matched.range)
  }
  /**
   Tokenize and lexicalize the raw string expression
   - parameter rawString: original string taken in
   - parameter beginIndex: the iteration beginning spot
   - returns: an array of tokens with labels
  */
  private func lexicalize(rawString: String, beginIndex: Int = 0) throws -> [Token] {
    guard beginIndex < rawString.count else { return [] }
    let range = NSRange(rawString.index(rawString.startIndex, offsetBy: beginIndex)..., in: rawString)
    if let (matchedNum, matchedRange) = match(string: rawString, regex: numberPattern, range: range) {
      let convertedNumber: Token
      switch matchedNum {
      case "PI", "π", "pi": convertedNumber = .number(.pi)
      default: convertedNumber = .number(Decimal(string: String(matchedNum))!)
      }
      return [convertedNumber] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    } else if let (_, matchedRange) = match(string: rawString, regex: openBracketPattern, range: range) {
      return [Token.openBracket] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    } else if let (_, matchedRange) = match(string: rawString, regex: closeBracketPattern, range: range) {
      return [Token.closeBracket] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    } else if let (binaryOp, matchedRange) = match(string: rawString, regex: binaryOperatorPattern, range: range) {
      let Operator: Token
      switch binaryOp {
      case "**", "^": Operator = .binaryOp(Decimal.pow, 3)
      case "*": Operator = .binaryOp(*, 2)
      case "/": Operator = .binaryOp(/, 2)
      case "%": Operator = .binaryOp(%, 2)
      case "+": Operator = .binaryOp(+, 1)
      case "-": Operator = .binaryOp(-, 1)
      default: throw MathExpressionError.invalidToken
      }
      return [Operator] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    } else if let (unaryOp, matchedRange) = match(string: rawString, regex: unaryOperatorPattern, range: range) {
      let Operator: Token
      switch unaryOp {
      case "log", "ln": Operator = .unaryOp(Decimal.log)
      case "sqrt", "√": Operator = .unaryOp(Decimal.sqrt)
      case "exp": Operator = .unaryOp(Decimal.exp)
      default: throw MathExpressionError.invalidToken
      }
      return [Operator] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    }
    throw MathExpressionError.invalidToken
  }
  
  func tokenize(rawString: String) throws -> [Token] {
    let procesingString = rawString.replacingOccurrences(of: " ", with: "")
    return try lexicalize(rawString: procesingString)
  }
  /**
   Match tokens with required grammars
   Possible grammars:
   Expression = Number
   Expression = Unary(Number) | Unary Number | UnaryNumber
   Expression = (Expression)
   Expression = Number Binary Number | Number Binary (Expression) | Number Binary Unary
   
   - parameter tokens: the tokens with labels
   - parameter token: early stop token, used to stop recursion in some certain conditions
   - returns: (The matched expression, current index)
   */
  private func grammerMatch(tokens: [Token], earlyStopAt token: Token? = nil) -> (MathExpression, Int)? {
    guard tokens.count > 0 else { return nil }
    var index = 0
    var expressions = [MathExpression]()
    while index < tokens.count {
      let processingToken = tokens[index]
      switch processingToken {
      case .number(let value): expressions.append(.value(value))// Number
        
      case .unaryOp(let op):
        guard tokens.count - index > 1 else { return nil }
        if case .number(let value) = tokens[index + 1] {// Unary followed by a number
          expressions.append(.unaryExp(Operator: op, value: .value(value)))
          index += 1
        } else if case .openBracket = tokens[index + 1] { // Unary followed by a bracket expression
          guard index + 2 < tokens.count, let (exp, movedIndex) = grammerMatch(tokens: Array(tokens[(index + 2)...])) else { return nil }
          index += movedIndex + 2
          expressions.append(.unaryExp(Operator: op, value: exp))
        } else { return nil }
        if case .unaryOp? = token, let expression = expressions.last { return (expression, index) }
        
      case .binaryOp(let op, let priority):
        guard tokens.count - index > 1 else { return nil }
        let currentIndex = index
        let preExp = expressions.count > 0 ? expressions.removeLast() : .value(0)// Allow - or + to be the first value
        let rightExp: MathExpression
        if case .number(let value) = tokens[index + 1] { rightExp = .value(value); index += 1 }
        else if case .openBracket = tokens[index + 1] {
          guard index + 2 < tokens.count, let (exp, movedIndex) = grammerMatch(tokens: Array(tokens[(index + 2)...])) else { return nil }
          index += movedIndex + 2
          rightExp = exp
        } else if case .unaryOp(_) = tokens[index + 1] {
          guard index + 1 < tokens.count, let (exp, movedIndex) = grammerMatch(tokens: Array(tokens[(index + 1)...]), earlyStopAt: tokens[index + 1]) else { return nil }
          index += movedIndex + 1
          rightExp = exp
        } else { return nil }
        switch preExp {
        case .binaryExp(lhs: let lhs, op: let Operator, priority: let existingPriority, rhs: let rhs):
          // If previous is a binary operator expression
          if existingPriority >= priority { fallthrough }
          else if case .closeBracket = tokens[currentIndex - 1] { fallthrough }
          else {// Mutate the calculation order is current operator has the higher priority
            expressions.append(.binaryExp(lhs: lhs, op: Operator, priority: existingPriority, rhs:
              .binaryExp(lhs: rhs, op: op, priority: priority, rhs: rightExp)))
          }
        // If the previous is a number or unary expression with a number
        default: expressions.append(.binaryExp(lhs: preExp, op: op, priority: priority, rhs: rightExp))
        }
        
      case .openBracket:
        guard index + 1 < tokens.count, let (exp, movedIndex) = grammerMatch(tokens: Array(tokens[(index + 1)...])) else { return nil }
        index += movedIndex + 1
        if expressions.isEmpty { expressions.append(exp) }
        else { return nil }
      case .closeBracket:
        guard expressions.count == 1, let expression = expressions.first else { return nil }
        return (expression, index)
      }
      index += 1
    }
    guard expressions.count == 1 else { return nil }
    return (expressions.removeLast(), index)
  }
  
  func parse(tokens: [Token]) -> MathExpression? {
    return grammerMatch(tokens: tokens)?.0
  }
}

private extension Decimal {
  
  static func pow(lhs: Decimal, rhs: Decimal) -> Decimal {
    return Foundation.pow(lhs, NSDecimalNumber(decimal: rhs).intValue)
  }
  
  static func log(_ value: Decimal) -> Decimal {
    return Decimal(Darwin.log(NSDecimalNumber(decimal: value).doubleValue))
  }
  
  static func sqrt(_ value: Decimal) -> Decimal {
    return Decimal(Darwin.sqrt(NSDecimalNumber(decimal: value).doubleValue))
  }
  
  static func exp(_ value: Decimal) -> Decimal {
    return Decimal(Darwin.exp(NSDecimalNumber(decimal: value).doubleValue))
  }
  
  static func % (lhs: Decimal, rhs: Decimal) -> Decimal {
    return Decimal(NSDecimalNumber(decimal: lhs).intValue % NSDecimalNumber(decimal: rhs).intValue)
  }
}
