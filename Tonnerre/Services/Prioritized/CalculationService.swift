//
//  CalculationService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Expression

struct CalculationService: TonnerreService {
  let keyword: String = ""
  let minTriggerNum: Int = 1
  let hasPreview: Bool = false
  let alterContent: String? = "Copy to clipboard"
  let icon: NSImage = #imageLiteral(resourceName: "calculator")

  func prepare(input: [String]) -> [Displayable] {
    let rawExpression = input.joined()
    let expression = Expression(rawExpression)
    guard let result = try? expression.evaluate() else { return [] }
    return [DisplayableContainer<Int>(name: "\(result)", content: rawExpression, icon: icon, innerItem: nil)]
  }

  func serve(source: Displayable, withCmd: Bool) {
    guard
      let result = source as? DisplayableContainer<Int>,
      let _ = Double(result.name)
    else { return }
    if withCmd {
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
    case 1...9: return 17 + convertToInt
    case 0: return 29
    default: return nil
    }
  }
}
