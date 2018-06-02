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
        self?.textField.keyDown(with: $0)
        self?.collectionView.keyDown(with: $0)
        return $0
      }
    }
  }
  
  override func viewDidAppear() {
    indexManager.check()
    _ = textField.becomeFirstResponder()
  }
  
  override func viewWillDisappear() {
    guard let monitor = keyboardMonitor else { return }
    NSEvent.removeMonitor(monitor)
    keyboardMonitor = nil
  }
  
  override func viewDidDisappear() {
    indexManager.stopListening()
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
}

extension ViewController: TonnerreFieldDelegate {
  func textDidChange(value: String) {
    collectionView.datasource = interpreter.interpret(rawCmd: value)
  }
}

extension ViewController: TonnerreCollectionViewDelegate {
  func tabPressed(service: Displayable) {
    if let serviceType = service as? TonnerreService {
      textField.autoComplete(cmd: serviceType.keyword)
    } else {
      textField.autoComplete(cmd: service.name)
    }
  }
  
  func openService(service: URL) {
    textField.stringValue = ""
    NSWorkspace.shared.open(service)
  }
}

