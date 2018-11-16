//
//  CalculationService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct CalculationService: BuiltInProvider {
  let keyword: String = ""
  let argLowerBound: Int = 1
  let argUpperBound: Int = Int.max
  let alterContent: String? = "Open calculator with this value in"
  let content: String = "A quick access to calculator. Select to copy to clipboard"
  let icon: NSImage = .calculator
  private let tokenizer = MathTokenizer()
  private let parser = MathParser()

  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    let rawExpression = input.joined()
    do {
      let tokens = try tokenizer.tokenize(expression: rawExpression)
      let calculationResult = try parser.parse(tokens: tokens)
      return [DisplayableContainer<Int>(name: "\(calculationResult.value)", content: rawExpression, icon: icon)]
    } catch MathError.zeroDivision {
      return [DisplayableContainer<Error>(name: "Error: 0 cannot be a denominator", content: rawExpression, icon: icon, placeholder: "")]
    } catch MathError.unclosedBracket {
      return [DisplayableContainer<Error>(name: "Error: A bracket is not closed", content: rawExpression, icon: icon, placeholder: "")]
    } catch MathError.missingBracket {
      return [DisplayableContainer<Error>(name: "Error: functions must be followed by brackets", content: rawExpression, icon: icon, placeholder: "")]
    } catch {
      return []
    }
  }

  func serve(service: DisplayProtocol, withCmd: Bool) {
    guard
      let result = service as? DisplayableContainer<Int>,
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
