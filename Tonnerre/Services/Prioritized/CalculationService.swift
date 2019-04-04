//
//  CalculationService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import MathParser

struct CalculationService: BuiltInProvider {
  let defaultKeyword: String = ""
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let alterContent: String? = "Open calculator with this value in"
  let content: String = "A quick access to calculator. Select to copy to clipboard"
  let icon: NSImage = .calculator
  private let parser = MathParser()

  func prepare(withInput input: [String]) -> [DisplayItem] {
    let rawExpression = input.joined()
    guard !rawExpression.isEmpty else { return [] }
    do {
      let calculationResult = try parser.parse(expression: rawExpression)
      return [DisplayContainer<Int>(name: "\(calculationResult)", content: rawExpression, icon: icon)]
    } catch MathParserError.zeroDivision {
      return [DisplayContainer<Error>(name: "Error: 0 cannot be a denominator", content: rawExpression, icon: icon, placeholder: "")]
    } catch MathParserError.unclosedBracket {
      return [DisplayContainer<Error>(name: "Error: A bracket is not closed", content: rawExpression, icon: icon, placeholder: "")]
    } catch MathParserError.missingBracket {
      return [DisplayContainer<Error>(name: "Error: functions must be followed by brackets", content: rawExpression, icon: icon, placeholder: "")]
    } catch MathParserError.extraToken {
      return [DisplayContainer<Error>(name: "Error: invalid expression", content: rawExpression, icon: icon, placeholder: "")]
    } catch {
      return []
    }
  }

  func serve(service: DisplayItem, withCmd: Bool) {
    guard
      let result = service as? DisplayContainer<Int>,
      let _ = Double(result.name)
    else { return }
    if !withCmd {
      let pasteboard: NSPasteboard = .general
      pasteboard.declareTypes([.string], owner: nil)
      pasteboard.setString(result.name, forType: .string)
    } else {
      let keys = result.name.compactMap(characterToKeycode).map(String.init).joined(separator: ",")
      let rawScript = """
                      tell application "Calculator"
                      activate
                      delay 0.1
                      repeat with k in {%@}
                        tell application "System Events" to tell process "Calculation" to key code k
                      end repeat
                      end tell
                      """
      let filledScript = String(format: rawScript, keys)
      guard let appleScript = NSAppleScript(source: filledScript) else { return }
      appleScript.executeAndReturnError(nil)
    }
  }
  
  private func characterToKeycode(char: Character) -> Int? {
    guard let convertToInt = Int(String(char)) else { return char == "." ? 47 : nil }
    switch convertToInt {
    case 0...7: return 82 + convertToInt
    case 8, 9: return 83 + convertToInt
    default: return nil
    }
  }
}
