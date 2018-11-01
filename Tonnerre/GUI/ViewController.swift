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
  
  private var lastQuery: String = ""
  private let asyncSession = TonnerreSession.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    NotificationCenter.default.addObserver(self, selector: #selector(asyncContentDidLoad(notification:)), name: .asyncLoadingDidFinish, object: nil)
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
  
  
  @objc private func asyncContentDidLoad(notification: Notification) {
    DispatchQueue.main.async { [unowned self] in
      guard
        case .service(let service, _)? = self.tableVC.datasource.first,
        let dataPack = notification.userInfo as? [String: Any],
        let asyncLoader = service as? AsyncLoadingProtocol,
        let content = dataPack["rawElements"] as? [Any]
      else { return }
      let processedData = asyncLoader.present(rawElements: content)
      if asyncLoader.mode == .append {
        self.tableVC.datasource += processedData
      } else if asyncLoader.mode == .replaced {
        self.tableVC.datasource = processedData
      }
    }
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
    case .service(provider: let provider, content: let service):
      fieldVC.iconView.image = provider is TNEServices ? service.icon : provider.icon
      fieldVC.resetIconView(check: true)
    }
  }
  
  func updatePlaceholder(service: ServicePack?) {
    guard service != nil else {
      fieldVC.placeholderString = ""
      return
    }
    let stringValue = (fieldVC.stringValue.components(separatedBy: .whitespaces).last
      ?? fieldVC.stringValue).lowercased()
    let serviceValue = service!.placeholder.lowercased()
    guard !stringValue.isEmpty, serviceValue.starts(with: stringValue) else {
      fieldVC.placeholderString = ""
      return
    }
    fieldVC.placeholderString = String(service!.placeholder[stringValue.endIndex...])
  }
  
  func tabPressed(service: ServicePack) {
    switch service {
    case .provider(origin: let service) where !type(of: service).keyword.isEmpty:
      fieldVC.autoComplete(cmd: type(of: service).keyword, appendingSpace: true)
    case .service(provider: _, content: let value) where !value.placeholder.isEmpty:
      if let tneService = value as? TNEScript {
        fieldVC.autoComplete(cmd: tneService.placeholder, appendingSpace: tneService.lowerBound > 0)
      } else if let webExt = value as? WebExt {
        fieldVC.autoComplete(cmd: webExt.placeholder, appendingSpace: webExt.argLowerBound > 0)
      } else if let tservice = value as? TonnerreService {
        fieldVC.autoComplete(cmd: type(of: tservice).keyword, appendingSpace: tservice.argLowerBound > 0)
      } else {
        fieldVC.autoComplete(cmd: value.name, appendingSpace: false)
      }
    default: return
    }
    _ = fieldVC.becomeFirstResponder()
    textDidChange(value: fieldVC.stringValue)
  }
  
  func retrieveLastQuery() {
    fieldVC.restore(lastQuery: lastQuery)
    textDidChange(value: fieldVC.stringValue)
  }
  
  func serve(_ servicePack: ServicePack, withCmd: Bool) {
    guard case .service(let provider, let service) = servicePack else { return }
    DispatchQueue.main.async {[weak self] in // hide the window, and avoid the beeping sound
      guard !(provider is TonnerreInstantService && withCmd == false) else { return }
      (self?.view.window as? BaseWindow)?.isHidden = true
      self?.fieldVC.stringValue = ""
    }
    let queue = DispatchQueue.global(qos: .userInitiated)
    let queryValue = fieldVC.stringValue
    queue.async { [unowned self] in
      self.lastQuery = queryValue
      provider.serve(source: service, withCmd: withCmd)
    }
  }
}
