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
  }
  
  override func viewDidAppear() {
    indexManager.check()
    _ = textField.becomeFirstResponder()
  }
  
  override func viewDidDisappear() {
    
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
  func serviceDidSelect(service: TonnerreService) {
    // Leave for future implementation
  }
  
  func keyDidPress(keyEvent: NSEvent) {
    switch (keyEvent.keyCode, keyEvent.modifierFlags) {
    case (125...126, _):
      collectionView.becomeFirstResponder()
      textField.canBeSwitched = false
    default:
      if !textField.canBeSwitched {
        textField.canBeSwitched = true
        _ = textField.becomeFirstResponder()
        textField.currentEditor()?.moveToEndOfDocument(nil)
      }
    }
  }
}

