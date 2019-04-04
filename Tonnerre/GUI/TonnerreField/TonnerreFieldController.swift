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
  
  /// Reset the icon back to Tonnerre app icon. Used to reset the colour
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
    
    adjustFieldsWidth(withString: "")
    textField.window?.makeFirstResponder(nil)
  }
  
  /// String value of the textField
  var stringValue: String {
    get {
      return textField.stringValue
    } set {
      if newValue.isEmpty { lastQuery = stringValue }
      textField.stringValue = newValue
    }
  }
  
  /// Placeholder value of the placeholderField
  var placeholderString: String? {
    get {
      return placeholderField.placeholderString
    } set {
      placeholderField.placeholderString = newValue
    }
  }
  
  /// Complete the existing string to the first component of placeholder or
  /// the name field
  ///
  /// e.g.:
  ///   - "**Vis**ual Studio Code" -> "**Visual** Studio Code"
  /// - parameter target: The given desired goal string value
  /// - parameter appendingSpace: If true, append a space after word completion.
  ///                         This is used specifically for keywords completion
  ///                         of providers with lowerbound ≥ 1
  func autoComplete(target: String, appendingSpace: Bool) {
    defer {
      textField.window?.makeFirstResponder(nil)
      hidePlaceholderField()
      controlTextDidChange(Notification(name: .init(""), object: textField))
    }
    let truncatedValue = stringValue.truncatedSpaces
    let tokens = truncatedValue.components(separatedBy: .whitespaces)
    guard !tokens.isEmpty else { return }
    let containsOperator = tokens.contains { $0 == "AND" || $0 == "OR" }
    guard !containsOperator else { return }
    if let placeholder = placeholderString, !placeholder.isEmpty {
      complete(withPlaceholder: placeholder)
    } else {
      stringValue = target
    }
    if appendingSpace { stringValue = (stringValue + " ").truncatedSpaces }
  }
  
  /// Update the textField with given string
  ///
  /// This method replaces the textField content, and adjust the placeholderField
  /// - parameter text: the target text needs to be changed to
  func updateField(text: String) {
    defer {
      textField.window?.makeFirstResponder(nil)
      hidePlaceholderField()
      controlTextDidChange(Notification(name: .init(""), object: textField))
    }
    stringValue = text
  }
  
  /// Append the first non-empty string component separated by whitespace of
  /// the placeholder to the existing stringValue
  /// - parameter placeholder: given placeholder
  private func complete(withPlaceholder placeholder: String) {
    var components = placeholder.components(separatedBy: .whitespaces)
    var appendingComponent = components.removeFirst()
    let characterSet = CharacterSet(charactersIn: "!@#$%^&*()-=+_[]{}\\|:\"'<>/?,.`~")
    let isAcceptable: (String) -> Bool = {
      !$0.isEmpty && !characterSet.contains($0.unicodeScalars.last!)
    }
    while !isAcceptable(appendingComponent) && components.count > 0 {
      appendingComponent += " " + components.removeFirst()
    }
    stringValue += appendingComponent + (components.count > 1 ? " " : "")
  }
  
  /// Restore last query into the textField
  func restore() {
    textField.stringValue = lastQuery
    adjustFieldsWidth(withString: lastQuery)
    textField.currentEditor()?.selectedRange = NSRange(location: lastQuery.count, length: 0)
  }
  
  /// Display a warning information in the placeholder field
  /// - parameter info: The warning information needs to be displayed.
  ///                   If nil, then the placeholder field will be set to empty
  func display(info: String?) {
    if let placeholder = info {
      textFieldWidth.constant = 0
      placeholderWidth.constant = 610
      placeholderString = placeholder
    } else {
      placeholderString = ""
      adjustFieldsWidth(withString: "")
    }
  }
  
  /// Records the previous text value in the textField
  private var oldValue: String = ""
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
          self?.hidePlaceholderField()// Keep the length to max
        } else if !now.trimmingCharacters(in: .whitespaces).isEmpty {// If user is deleting the text or not editing anymore
          self?.adjustFieldsWidth(withString: now)// Adjust the size
        }
      }
    } else {// If the text is empty
      adjustFieldsWidth(withString: "")
      lastQuery = oldValue
      placeholderField.placeholderString = nil
    }
    oldValue = current
    delegate?.textDidChange(value: trimmedValue)
  }
  
  func controlTextDidEndEditing(_ obj: Notification) {
    if (obj.object as? NSTextField)?.stringValue.isEmpty ?? true { adjustFieldsWidth(withString: "") }
    guard (obj.userInfo?["NSTextMovement"] as? Int) == 16 else { return }
    delegate?.serviceDidSelect()
  }
  
  func controlTextDidBeginEditing(_ obj: Notification) {
    hidePlaceholderField()
  }
  
  private func calculateSize(value: String) -> NSSize {
    let cell = NSTextFieldCell(textCell: value)
    cell.attributedStringValue = NSAttributedString(string: value, attributes: [.font: textField.font!])
    return cell.cellSize
  }
  
  /**
   Make the editing area full length
   */
  private func hidePlaceholderField() {
    let maxWidth: CGFloat = 610
    textFieldWidth.constant = maxWidth
    placeholderWidth.constant = 0
  }
  
  /**
   Make the editing area as long as the string
   - parameter string: current displaying value
   */
  private func adjustFieldsWidth(withString string: String) {
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
