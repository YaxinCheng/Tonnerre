//
//  ViewController.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import LiteTableView

final class ViewController: NSViewController {
  var interpreter = TonnerreInterpreter()

  private lazy var tableVC: LiteTableViewController = {
    let storyboard = NSStoryboard(name: "LiteTableViewController", bundle: .main)
    let liteTableVC = storyboard.instantiateController(withIdentifier: "tableView") as! LiteTableViewController
    liteTableVC.delegate = self
    return liteTableVC
  }()
  
  private lazy var fieldVC: TonnerreFieldController = {
    let storyboard = NSStoryboard(name: "TonnerreField", bundle: .main)
    let fieldController = storyboard.instantiateController(withIdentifier: "TonnerreField") as! TonnerreFieldController
    fieldController.delegate = self
    return fieldController
  }()
  
  private let asyncSession = TonnerreSession.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    view.wantsLayer = true
    view.layer?.masksToBounds = true
    view.layer?.cornerRadius = 7
    
    loadField()
    loadTableView()
  }
  
  private func loadField() {
    view.addSubview(fieldVC.view)
    NSLayoutConstraint.activate([
      fieldVC.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      fieldVC.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      fieldVC.view.topAnchor.constraint(equalTo: view.topAnchor),
      fieldVC.view.heightAnchor.constraint(equalToConstant: 56),
    ])
  }
  
  private func loadTableView() {
    view.addSubview(tableVC.view)
    NSLayoutConstraint.activate([
      tableVC.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      tableVC.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      tableVC.view.topAnchor.constraint(equalTo: fieldVC.iconView.bottomAnchor, constant: 8),
      tableVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}

extension ViewController: TonnerreFieldDelegate {
  func textDidChange(value: String) {
    asyncSession.cancel()
    tableVC.datasource = interpreter.interpret(input: value)
    guard value.isEmpty else { return }
    interpreter.clearCache()// Essential to prevent showing unnecessary placeholders
    fieldVC.resetIconView()
  }
  
  func serviceDidSelect() {
    guard let servicePack = tableVC.retrieveHighlighted() else { return }
    serve(servicePack, withCmd: false)
  }
}

extension ViewController: LiteTableVCDelegate {
  func serviceHighlighted(service: ServicePack?) {
    guard service != nil else {
      fieldVC.resetIconView()
      return
    }
    switch service! {
    case .provider(let provider):
      fieldVC.iconView.image = provider.icon
    case .service(provider: let provider, content: _):
      fieldVC.iconView.image = provider.icon
      fieldVC.resetIconView(check: true)
    }
  }
  
  func updatePlaceholder(service: ServicePack?) {
    guard let servicePack = service else {
      fieldVC.placeholderString = ""
      return
    }
    let placeholder: String
    switch servicePack {
    case .provider(_):
      if fieldVC.stringValue.hasSuffix(" ") { placeholder = "" }
      else {
        placeholder = servicePack.placeholder.formDifference(with: fieldVC.stringValue)
      }
    case .service(provider: let provider, content: _):
      let queryComponents = fieldVC.stringValue.components(separatedBy: .whitespaces)
      let hasKeyword = !provider.keyword.isEmpty
        && provider.keyword.starts(with: queryComponents.first!)
        && (provider.defered || provider.argLowerBound > 0)
      let hasSpace = fieldVC.stringValue.contains(" ")
      let processingPart = hasKeyword ? queryComponents.dropFirst().joined(separator: " ") : fieldVC.stringValue
      placeholder = (hasKeyword && !hasSpace ? " " : "") + servicePack.placeholder.formDifference(with: processingPart)
    }
    fieldVC.placeholderString = placeholder
  }
  
  func updatePlaceholder(string: String?) {
    fieldVC.display(info: string)
  }
  
  func tabPressed(service: ServicePack) {
    switch service {
    case .provider(origin: let provider):
      fieldVC.autoComplete(cmd: provider.keyword, appendingSpace: provider.argLowerBound > 0
        , hasKeyword: false)
    case .service(provider: let provider, content: let service):
      fieldVC.autoComplete(cmd: service.placeholder, appendingSpace: false,
                           hasKeyword: provider.keyword.starts(with: fieldVC.firstValue.lowercased()))
    }
    _ = fieldVC.becomeFirstResponder()
    textDidChange(value: fieldVC.stringValue)
  }
  
  func retrieveLastQuery() {
    fieldVC.restore()
    textDidChange(value: fieldVC.stringValue)
  }
  
  func serve(_ servicePack: ServicePack, withCmd: Bool) {
    guard case .service(provider: let provider, content: let service) = servicePack else { return }
    DispatchQueue.global(qos: .userInitiated).async { [provider, service, withCmd] in
      provider.serve(service: service, withCmd: withCmd)
    }
    DispatchQueue.main.async { [weak self, provider] in // hide the window, and avoid the beeping sound
      (self?.view.window as? BaseWindow)?.isHidden = true
      self?.fieldVC.stringValue = ""
      LaunchOrder.save(with: provider.id)
    }
  }
}
