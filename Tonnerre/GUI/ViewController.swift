//
//  ViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  var interpreter = TonnerreInterpreter()
  
  @IBOutlet weak var backgroundView: NSVisualEffectView!
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var textField: TonnerreField!
  @IBOutlet weak var placeholderField: PlaceholderField!
  @IBOutlet weak var collectionView: TonnerreCollectionView!
  @IBOutlet weak var textFieldWidth: NSLayoutConstraint!
  @IBOutlet weak var placeholderWidth: NSLayoutConstraint!
  
  private var keyboardMonitor: Any? = nil
  private var flagsMonitor: Any? = nil
  private var lastQuery: String = ""
  private let suggestionSession = TonnerreSuggestionSession.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    textField.delegate = self
    collectionView.delegate = self
    NotificationCenter.default.addObserver(self, selector: #selector(suggestionNotificationDidArrive(notification:)), name: .suggestionDidFinish, object: nil)
    view.layer?.masksToBounds = true
    view.layer?.cornerRadius = 7
  }
  
  override func viewWillAppear() {
    if TonnerreTheme.current == .dark {
      backgroundView.material = .dark
    } else {
      backgroundView.material = .mediumLight
    }
    iconView.theme = .current
    textField.theme = .current
    placeholderField.theme = .current
    if keyboardMonitor == nil {
      keyboardMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] in
        self?.collectionView.keyDown(with: $0)
        return $0
      }
      flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] in
        self?.collectionView.modifierChanged(with: $0)
        return $0
      }
    }
  }
  
  override func viewDidAppear() {
    _ = textField.becomeFirstResponder()
  }
  
  override func viewWillDisappear() {
    guard let kmonitor = keyboardMonitor else { return }
    NSEvent.removeMonitor(kmonitor)
    keyboardMonitor = nil
    guard let fmonitor = flagsMonitor else { return }
    NSEvent.removeMonitor(fmonitor)
    flagsMonitor = nil
    adjustEditing(withString: "")
    textField.window?.makeFirstResponder(nil)
  }

  private func refreshIcon() {
    iconView.image = #imageLiteral(resourceName: "tonnerre")
    iconView.theme = .current
  }
  
  @objc private func suggestionNotificationDidArrive(notification: Notification) {
    DispatchQueue.main.async { [unowned self] in
      guard
        case .result(let service, _)? = self.collectionView.datasource.first,
        let suggestionPack = notification.userInfo as? [String: Any],
        let suggestions = suggestionPack["suggestions"] as? [String],
        let webService = service as? WebService
      else { return }
      self.collectionView.datasource += webService.encodedSuggestions(queries: suggestions)
    }
  }
  
  private func textDidChange(value: String) {
    collectionView.datasource = interpreter.interpret(rawCmd: value)
    guard value.isEmpty else { return }
    interpreter.clearCache()
    refreshIcon()
  }
}

extension ViewController: NSTextFieldDelegate {
  override func controlTextDidChange(_ obj: Notification) {
    guard let objTextField = obj.object as? TonnerreField, textField ===  objTextField else { return }
    let current = objTextField.stringValue// Capture the current value
    if !current.isEmpty {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in// dispatch after 1 second
        guard let now = self?.textField.stringValue else { return } // Test the current value (after 1 second)
        if now.count > current.count {// If the length is increasing, means there are more to type
          self?.fullEditing()// Keep the length to max
        } else if !now.isEmpty {// If user is deleting the text or not editing anymore
          self?.adjustEditing(withString: now)// Adjust the size
        }
      }
    } else {// If the text is empty
      adjustEditing(withString: "")
      placeholderField.placeholderString = nil
    }
    suggestionSession.cancel()
    let text = textField.stringValue
    textDidChange(value: text)
  }
  
  override func controlTextDidEndEditing(_ obj: Notification) {
    if (obj.object as? NSTextField)?.stringValue.isEmpty ?? true { adjustEditing(withString: "") }
    guard (obj.userInfo?["NSTextMovement"] as? Int) == 16 else { return }
    guard let (service, value) = collectionView.enterPressed() else { return }
    serve(with: service, target: value, withCmd: false)
  }
  
  override func controlTextDidBeginEditing(_ obj: Notification) {
    fullEditing()
  }
  
  private func calculateSize(value: String) -> NSSize {
    let cell = NSTextFieldCell(textCell: value)
    cell.attributedStringValue = NSAttributedString(string: value, attributes: [.font: NSFont.systemFont(ofSize: 35)])
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
    let width = string.isEmpty ? minSize.width : cellSize.width
    textFieldWidth.constant = width
    placeholderWidth.constant = 610 - width
    guard let position = textField.currentEditor()?.selectedRange.location else { return }
    textField.window?.makeFirstResponder(nil)// End the editing status
    textField.window?.makeFirstResponder(textField)
    textField.currentEditor()?.selectedRange = NSRange(location: position, length: 0)
  }
}

extension ViewController: TonnerreCollectionViewDelegate {
  func viewIsClicked() {
    textField.becomeFirstResponder()
    textField.currentEditor()?.selectedRange = NSRange(location: textField.stringValue.count, length: 0)
  }
  
  func retrieveLastQuery() {
    textField.stringValue = lastQuery
    textDidChange(value: textField.stringValue)
    adjustEditing(withString: lastQuery)
  }
  
  func serve(with service: TonnerreService, target: Displayable, withCmd: Bool) {
    DispatchQueue.main.async {[weak self] in // hide the window, and avoid the beeping sound
      guard !(service is TonnerreInterpreterService) else { return }
      (self?.view.window as? BaseWindow)?.isHidden = true
      self?.refreshIcon()
      self?.textField.stringValue = ""
    }
    let queue = DispatchQueue.global(qos: .userInitiated)
    let queryValue = textField.stringValue
    queue.async { [unowned self] in
      self.lastQuery = queryValue
      service.serve(source: target, withCmd: withCmd)
    }
  }
  
  func tabPressed(service: ServiceResult) {
    switch service {
    case .service(origin: let service) where !type(of: service).keyword.isEmpty:
      textField.autoComplete(cmd: type(of: service).keyword)
    case .result(service: let service, value: let value) where !value.name.isEmpty:
      if let extService = service as? TonnerreExtendService {
        textField.autoComplete(cmd: extService.keyword)
      } else if let tservice = value as? TonnerreService {
        textField.autoComplete(cmd: type(of: tservice).keyword)
      } else {
        textField.autoComplete(cmd: value.name)
      }
    default: return
    }
    fullEditing()
    textDidChange(value: textField.stringValue)
  }
  
  func serviceHighlighted(service: ServiceResult?) {
    guard service != nil else { refreshIcon(); return }
    switch service! {
    case .service(origin: let service):
      iconView.image = service.icon
    case .result(service: let service, value: let value):
      iconView.image = service is DynamicService ? value.icon : service.icon
      if iconView.image === #imageLiteral(resourceName: "tonnerre") {
        refreshIcon()
      }
    }
  }
  
  func fillPlaceholder(with service: ServiceResult?) {
    guard let data = service else {
      placeholderField.placeholderString = ""
      return
    }
    let stringValue = textField.stringValue.components(separatedBy: .whitespaces).last?.lowercased() ?? textField.stringValue
    let serviceValue = data.placeholder.lowercased()
    guard !stringValue.isEmpty, serviceValue.starts(with: stringValue) else {
      placeholderField.placeholderString = ""
      return
    }
    let placeholder = String(serviceValue[stringValue.endIndex...])
    placeholderField.placeholderString = placeholder
  }
}

