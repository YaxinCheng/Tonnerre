//
//  TonnerreFieldController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-01.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TonnerreFieldController: NSViewController {
  
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var textField: TonnerreField! {
    didSet { textField.delegate = self }
  }
  @IBOutlet weak var placeholderField: PlaceholderField!
  weak var delegate: TonnerreFieldDelegate?
  @IBOutlet weak var textFieldWidth: NSLayoutConstraint!
  @IBOutlet weak var placeholderWidth: NSLayoutConstraint!
  
  var firstValue: String {
    guard let spaceIndex = stringValue.firstIndex(of: " ") else { return stringValue }
    return String(stringValue[..<spaceIndex])
  }
  
  func resetIconView(check: Bool = false) {
    if iconView.image === #imageLiteral(resourceName: "tonnerre") || !check {
      iconView.image = #imageLiteral(resourceName: "tonnerre")
    }
  }
  
  override func becomeFirstResponder() -> Bool {
    return textField.becomeFirstResponder()
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    resetIconView()
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    _ = textField.becomeFirstResponder()
  }
  
  override func viewWillDisappear() {
    super.viewWillDisappear()
    
    adjustEditing(withString: "")
    textField.window?.makeFirstResponder(nil)
  }
  
  var stringValue: String {
    get {
      return textField.stringValue
    } set {
      textField.stringValue = newValue
    }
  }
  
  var placeholderString: String? {
    get {
      return placeholderField.placeholderString
    } set {
      placeholderField.placeholderString = newValue
    }
  }
  
  private let stringWithOperator = try! NSRegularExpression(pattern: "^.+?(\\s(AND|OR)\\s.+?)+", options: .anchorsMatchLines)
  
  func autoComplete(cmd: String, appendingSpace: Bool, hasKeyword: Bool) {
    defer {
      textField.window?.makeFirstResponder(nil)
      fullEditing()
    }
    guard
      stringWithOperator.numberOfMatches(in: stringValue, options: .anchored, range: NSRange(stringValue.startIndex..., in: stringValue)) < 1
      else {
        stringValue = cmd + (appendingSpace ? " " : "")
        return
    }
    let tokens = stringValue.trimmed.components(separatedBy: .whitespaces)
    guard !tokens.isEmpty else { return }
    if hasKeyword && tokens.count > 1 {
      let toBeCompletedString = tokens[1...].joined(separator: " ")
      let commonPart = String(zip(toBeCompletedString, cmd).map { $0.0 })
      let surplusPart = String(cmd[commonPart.endIndex...])
      stringValue = (tokens.first! + " " + commonPart + surplusPart).lowercased()
    } else {
      stringValue = cmd + (appendingSpace ? " " : "")
    }
  }
  
  func restore(lastQuery: String) {
    textField.stringValue = lastQuery
    adjustEditing(withString: lastQuery)
    textField.currentEditor()?.selectedRange = NSRange(location: lastQuery.count, length: 0)
  }
  
  func display(info: String?) {
    if let placeholder = info {
      textFieldWidth.constant = 0
      placeholderWidth.constant = 610
      placeholderString = placeholder
    } else {
      placeholderString = ""
      adjustEditing(withString: "")
    }
  }
}

extension TonnerreFieldController: NSTextFieldDelegate {
  func controlTextDidChange(_ obj: Notification) {
    guard let objTextField = obj.object as? TonnerreField, textField ===  objTextField else { return }
    let current = objTextField.stringValue// Capture the current value
    let trimmedValue = current.trimmed// Trim current
    if !current.isEmpty {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in// dispatch after 0.4 second
        guard let now = self?.textField.stringValue else { return } // Test the current value (after 0.4 second)
        if now.count > current.count {// If the length is increasing, means there are more to type
          self?.fullEditing()// Keep the length to max
        } else if !now.trimmingCharacters(in: .whitespaces).isEmpty {// If user is deleting the text or not editing anymore
          self?.adjustEditing(withString: now)// Adjust the size
        }
      }
    } else {// If the text is empty
      adjustEditing(withString: "")
      placeholderField.placeholderString = nil
    }
    delegate?.textDidChange(value: trimmedValue)
  }
  
  func controlTextDidEndEditing(_ obj: Notification) {
    if (obj.object as? NSTextField)?.stringValue.isEmpty ?? true { adjustEditing(withString: "") }
    guard (obj.userInfo?["NSTextMovement"] as? Int) == 16 else { return }
    delegate?.serviceDidSelect()
  }
  
  func controlTextDidBeginEditing(_ obj: Notification) {
    fullEditing()
  }
  
  private func calculateSize(value: String) -> NSSize {
    let cell = NSTextFieldCell(textCell: value)
    cell.attributedStringValue = NSAttributedString(string: value, attributes: [.font: NSFont.systemFont(ofSize: 33.5)])
    return cell.cellSize
  }
  
  /**
   Make the editing area full length
   */
  private func fullEditing() {
    let maxWidth: CGFloat = 610
    textFieldWidth.constant = maxWidth
    placeholderWidth.constant = 0
  }
  
  /**
   Make the editing area as long as the string
   - parameter string: current displaying value
   */
  private func adjustEditing(withString string: String) {
    let cellSize = calculateSize(value: string)
    let minSize = calculateSize(value: "Tonnerre")
    let width = min(string.isEmpty ? minSize.width : cellSize.width, 610)
    textFieldWidth.constant = width
    placeholderWidth.constant = 610 - width
    guard let position = textField.currentEditor()?.selectedRange.location else { return }
    textField.window?.makeFirstResponder(nil)// End the editing status
    textField.window?.makeFirstResponder(textField)
    textField.currentEditor()?.selectedRange = NSRange(location: position, length: 0)
  }
}
