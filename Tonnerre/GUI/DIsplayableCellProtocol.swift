//
//  DIsplayableCellProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-15.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol DisplayableCellProtocol: class {
  var view: NSView { get set }
  var iconView: TonnerreIconView! { get set }
  var serviceLabel: NSTextField! { get set }
  var introLabel: NSTextField! { get set }
  var highlighted: Bool { get set }
  var displayItem: Displayable? { get set }
}

extension DisplayableCellProtocol {
  var highlighted: Bool {
    set {
      DispatchQueue.main.async { [weak self] in
        if newValue {
          self?.view.layer?.backgroundColor = NSColor(calibratedRed: 99/255, green: 147/255, blue: 1, alpha: 0.6).cgColor
        } else {
          self?.view.layer?.backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0).cgColor
        }
      }
    } get {
      return view.layer?.backgroundColor == NSColor(calibratedRed: 99/255, green: 147/255, blue: 1, alpha: 0.6).cgColor
    }
  }
}
