//
//  ViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  let indexManager = CoreIndexing()
  let interpreter = TonnerreInterpreter()
  
  @IBOutlet weak var backgroundView: NSVisualEffectView!
  @IBOutlet weak var iconView: TonnerreIconView!
  @IBOutlet weak var textField: TonnerreField!
  @IBOutlet weak var collectionView: TonnerreCollectionView!
  private var keyboardMonitor: Any? = nil
  private var flagsMonitor: Any? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    textField.tonnerreDelegate = self
    collectionView.delegate = self
  }
  
  override func viewWillAppear() {
    if TonnerreTheme.currentTheme == .dark {
      iconView.theme = .dark
      textField.theme = .dark
      backgroundView.material = .dark
    } else {
      iconView.theme = .dark
      textField.theme = .dark
      backgroundView.material = .light
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
    indexManager.check()
    _ = textField.becomeFirstResponder()
  }
  
  override func viewWillDisappear() {
    guard let kmonitor = keyboardMonitor, let fmonitor = flagsMonitor else { return }
    NSEvent.removeMonitor(kmonitor)
    keyboardMonitor = nil
    NSEvent.removeMonitor(fmonitor)
    flagsMonitor = nil
  }
  
  override func viewDidDisappear() {
    indexManager.stopListening()
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  private func refreshIcon() {
    iconView.image = #imageLiteral(resourceName: "tonnerre")
    iconView.theme = TonnerreTheme.currentTheme
  }
}

extension ViewController: TonnerreFieldDelegate {
  func textDidChange(value: String) {
    collectionView.datasource = interpreter.interpret(rawCmd: value)
    guard value.isEmpty else { return }
    refreshIcon()
  }
}

extension ViewController: TonnerreCollectionViewDelegate {
  func serve(with service: TonnerreService, target: Displayable, withCmd: Bool) {
    service.serve(source: target, withCmd: withCmd)
    textField.stringValue = ""
    refreshIcon()
    guard let window = view.window as? BaseWindow else { return }
    window.isHidden = true
  }
  
  func tabPressed(service: ServiceResult) {
    switch service {
    case .service(origin: let service):
      textField.autoComplete(cmd: service.keyword)
    case .result(service: _, value: let value):
      textField.autoComplete(cmd: value.name)
    }
  }
  
  func serviceHighlighted(service: ServiceResult) {
    switch service {
    case .service(origin: let service):
      iconView.image = service.icon
    case .result(service: let service, value: _):
      iconView.image = service.icon
    }
    refreshIcon()
  }
}

