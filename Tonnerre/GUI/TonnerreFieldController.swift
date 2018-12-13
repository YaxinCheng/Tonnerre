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
  private var lastQuery: String = ""
  
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
    placeholderField.font = textField.font
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
      if newValue.isEmpty { lastQuery = textField.stringValue }
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
  
  func autoComplete(cmd: String, appendingSpace: Bool, hasKeyword: Bool) {
    defer {
      textField.window?.makeFirstResponder(nil)
      fullEditing()
      controlTextDidChange(Notification(name: .init(""), object: textField))
    }
    let truncatedValue = stringValue.truncatedSpaces
    let tokens = truncatedValue.components(separatedBy: .whitespaces)
    guard !tokens.isEmpty else { return }
    let containsOperator = tokens.contains { $0 == "AND" || $0 == "OR" }
    guard !containsOperator else { return }
    if let placeholder = placeholderString, !placeholder.isEmpty {
      var components = placeholder.components(separatedBy: .whitespaces)
      var firstValue = components.removeFirst()
      while firstValue == "" && components.count > 0 {
        firstValue += " " + components.removeFirst()
      }
      stringValue += firstValue + (components.count > 1 ? " " : "")
    } else {
      let finishedCompletion = stringValue.range(of: cmd, options: .caseInsensitive) != nil
      guard !finishedCompletion else { return }
      let existingComponents = truncatedValue.components(separatedBy: .whitespaces)
      let completeComponents = cmd.components(separatedBy: .whitespaces)
      let existingExceptLast = existingComponents.dropLast().joined(separator: " ")
      let appendingPart = completeComponents.first!
      let completed = (existingExceptLast + " " + appendingPart).truncatedSpaces
      let suffixSpace = completeComponents.count > 1 ? " " : ""
      stringValue = completed + suffixSpace
    }
    if appendingSpace { stringValue = (stringValue + " ").truncatedSpaces }
  }
  
  func restore() {
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
    guard let objTextField = obj.object as? TonnerreField, textField === objTextField else { return }
    let current = objTextField.stringValue// Capture the current value
    let trimmedValue = current.truncatedSpaces// Trim current
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
    cell.attributedStringValue = NSAttributedString(string: value, attributes: [.font: textField.font!])
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
