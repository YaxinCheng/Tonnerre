//
//  ViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {
  var interpreter = TonnerreInterpreter()
  
  @IBOutlet weak var backgroundView: NSVisualEffectView!
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var textField: TonnerreField! {
    didSet { textField.delegate = self }
  }
  @IBOutlet weak var placeholderField: PlaceholderField!
  @IBOutlet weak var collectionView: TonnerreCollectionView! {
    didSet { collectionView.delegate = self }
  }
  @IBOutlet weak var textFieldWidth: NSLayoutConstraint!
  @IBOutlet weak var placeholderWidth: NSLayoutConstraint!
  
  private var keyboardMonitor: Any? = nil
  private var flagsMonitor: Any? = nil
  private var lastQuery: String = ""
  private let asyncSession = TonnerreSession.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    NotificationCenter.default.addObserver(self, selector: #selector(asyncContentDidLoad(notification:)), name: .asyncLoadingDidFinish, object: nil)
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
  
  @objc private func asyncContentDidLoad(notification: Notification) {
    DispatchQueue.main.async { [unowned self] in
      guard
        case .service(let service, _)? = self.collectionView.datasource.first,
        let dataPack = notification.userInfo as? [String: Any],
        let asyncLoader = service as? AsyncLoadingProtocol,
        let content = dataPack["rawElements"] as? [Any]
      else { return }
      let processedData = asyncLoader.present(rawElements: content)
      if asyncLoader.mode == .append {
        self.collectionView.datasource += processedData
      } else if asyncLoader.mode == .replaced {
        self.collectionView.datasource = processedData
      }
    }
  }
  
  private func textDidChange(value: String) {
    collectionView.datasource = interpreter.interpret(input: value)
    guard value.isEmpty else { return }
    interpreter.clearCache()// Essential to prevent showing unnecessary placeholders
    refreshIcon()
  }
}

extension ViewController: NSTextFieldDelegate {
  func controlTextDidChange(_ obj: Notification) {
    guard let objTextField = obj.object as? TonnerreField, textField ===  objTextField else { return }
    let current = objTextField.stringValue// Capture the current value
    let trimmedValue = current.replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)
      .replacingOccurrences(of: "\\s\\s+", with: " ", options: .regularExpression)// Trim current
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
    asyncSession.cancel()
    textDidChange(value: trimmedValue)
  }
  
  func controlTextDidEndEditing(_ obj: Notification) {
    if (obj.object as? NSTextField)?.stringValue.isEmpty ?? true { adjustEditing(withString: "") }
    guard (obj.userInfo?["NSTextMovement"] as? Int) == 16 else { return }
    guard let (service, value) = collectionView.enterPressed() else { return }
    serve(with: service, target: value, withCmd: false)
  }
  
  func controlTextDidBeginEditing(_ obj: Notification) {
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
    let width = min(string.isEmpty ? minSize.width : cellSize.width, 610)
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
    textField.currentEditor()?.selectedRange = NSRange(location: lastQuery.count, length: 0)
  }
  
  func serve(with service: TonnerreService, target: DisplayProtocol, withCmd: Bool) {
    DispatchQueue.main.async {[weak self] in // hide the window, and avoid the beeping sound
      guard !(service is TonnerreInstantService && withCmd == false) else { return }
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
  
  func tabPressed(service: ServicePack) {
    switch service {
    case .provider(origin: let service) where !type(of: service).keyword.isEmpty:
      textField.autoComplete(cmd: type(of: service).keyword)
    case .service(provider: let service, content: let value) where !value.name.isEmpty:
      if service is TNEScript || service is WebExt {
        textField.autoComplete(cmd: value.placeholder)
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
  
  func serviceHighlighted(service: ServicePack?) {
    guard service != nil else { refreshIcon(); return }
    switch service! {
    case .provider(let provider):
      iconView.image = provider.icon
    case .service(provider: let provider, content: let service):
      iconView.image = provider is TNEServices ? service.icon : provider.icon
      if iconView.image === #imageLiteral(resourceName: "tonnerre") {
        refreshIcon()
      }
    }
  }
  
  func fillPlaceholder(with service: ServicePack?) {
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

