//
//  MathExpression.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

indirect enum MathExpression {
  case value(Decimal)
  case unaryExp(Operator: (Decimal)->Decimal, value: MathExpression)
  case binaryExp(lhs: MathExpression, op: (Decimal, Decimal)->Decimal, priority: Int, rhs: MathExpression)
  
  func eval() -> Decimal? {
    switch self {
    case .value(let value): return value
    case .unaryExp(Operator: let op, value: let value):
      guard let evalValue = value.eval() else { return nil }
      return op(evalValue)
    case .binaryExp(lhs: let left, op: let Operator, priority: _, rhs: let right):
      guard let l = left.eval(), let r = right.eval() else { return nil }
      return Operator(l, r)
    }
  }
}

enum MathExpressionError: Error {
  case invalidToken
}
