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
    case number(Double)
    case openBracket
    case closeBracket
    case binaryOp((Double, Double)->Double, Int)
    case unaryOp((Double)->Double)
  }
  
  private let numberPattern = "^(\\d*\\.\\d+)|^(\\d+)|^(PI)|^π|^(pi)"
  private let binaryOperatorPattern = "^\\*\\*|[+\\-*/%^]"
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
    case "**", "^": Operator = .binaryOp(pow, 3)
    case "*": Operator = .binaryOp(*, 2)
    case "/": Operator = .binaryOp(/, 2)
    case "%": Operator = .binaryOp(%, 2)
    case "+": Operator = .binaryOp(+, 1)
    case "-": Operator = .binaryOp(-, 1)
    default: throw MathExpressionError.invalidToken
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
    default: throw MathExpressionError.invalidToken
    }
    return Operator
  }
  
  private func constant(matchWith string: Substring) -> Token {
    let convertedConstant: Token
    switch string {
    case "PI", "π", "pi": convertedConstant = .number(.pi)
    default: convertedConstant = .number(Double(String(string))!)
    }
    return convertedConstant
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
      let convertedNumber = constant(matchWith: matchedNum)
      return [convertedNumber] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    } else if let (_, matchedRange) = match(string: rawString, regex: openBracketPattern, range: range) {
      return [Token.openBracket] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    } else if let (_, matchedRange) = match(string: rawString, regex: closeBracketPattern, range: range) {
      return [Token.closeBracket] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    } else if let (binaryOp, matchedRange) = match(string: rawString, regex: binaryOperatorPattern, range: range) {
      let Operator = try binaryOperator(matchWith: binaryOp)
      return [Operator] + (try lexicalize(rawString: rawString, beginIndex: beginIndex + matchedRange.length))
    } else if let (unaryOp, matchedRange) = match(string: rawString, regex: unaryOperatorPattern, range: range) {
      let Operator = try unaryOperator(matchWith: unaryOp)
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

extension Double {
  static func % (lhs: Double, rhs: Double) -> Double {
    return Double(Int(lhs) % Int(rhs))
  }
}
