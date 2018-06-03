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
    guard value.isEmpty else { return }
    iconView.image = #imageLiteral(resourceName: "tonnerre")
    iconView.theme = TonnerreTheme.currentTheme
  }
}

extension ViewController: TonnerreCollectionViewDelegate {
  func serviceHighlighted(service: Displayable) {
    if let actualService = service as? TonnerreService {
      iconView.image = actualService.icon
    } else if let urlResult = service as? URL {
      let workspace = NSWorkspace.shared
      if let actualService = workspace.urlForApplication(toOpen: urlResult) {
        let icon = workspace.icon(forFile: actualService.path)
        icon.size = NSSize(width: 96, height: 96)
        iconView.image = icon
      }
    } else {
      iconView.image = #imageLiteral(resourceName: "tonnerre")
    }
  }
  
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

