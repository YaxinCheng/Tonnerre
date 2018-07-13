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
  @IBOutlet weak var collectionView: TonnerreCollectionView!
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
      iconView.theme = .dark
      textField.theme = .dark
      backgroundView.material = .dark
    } else {
      iconView.theme = .dark
      textField.theme = .dark
      backgroundView.material = .mediumLight
    }
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
    iconView.theme = .current
    textField.theme = .current
  }
  
  override func viewWillDisappear() {
    guard let kmonitor = keyboardMonitor else { return }
    NSEvent.removeMonitor(kmonitor)
    keyboardMonitor = nil
    guard let fmonitor = flagsMonitor else { return }
    NSEvent.removeMonitor(fmonitor)
    flagsMonitor = nil
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
    suggestionSession.cancel()
    let text = textField.stringValue
    textDidChange(value: text)
  }
  
  override func controlTextDidEndEditing(_ obj: Notification) {
    guard (obj.userInfo?["NSTextMovement"] as? Int) == 16 else { return }
    guard let (service, value) = collectionView.enterPressed() else { return }
    serve(with: service, target: value, withCmd: false)
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
    case .result(service: _, value: let value) where !value.name.isEmpty:
      if let service = value as? TonnerreService {
        textField.autoComplete(cmd: type(of: service).keyword)
      } else {
        textField.autoComplete(cmd: value.name)
      }
    default: return
    }
    textDidChange(value: textField.stringValue)
  }
  
  func serviceHighlighted(service: ServiceResult?) {
    guard service != nil else { refreshIcon(); return }
    switch service! {
    case .service(origin: let service):
      iconView.image = service.icon
    case .result(service: let service, value: _):
      iconView.image = service.icon
      if iconView.image === #imageLiteral(resourceName: "tonnerre") {
        refreshIcon()
      }
    }
  }
}

