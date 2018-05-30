//
//  TonnerreFieldHandler.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

extension ViewController: NSTextFieldDelegate {
  override func controlTextDidChange(_ obj: Notification) {
    guard let textField = obj.object as? TonnerreField else { return }
    let text = textField.stringValue
    let test = Set<String>(["f", "fi", "fil", "file"])
    datasource.removeAll(keepingCapacity: true)
    if test.contains(text.lowercased()) {
      let service = FileNameSearchService()
      datasource.append(service)
    }
  }
}
