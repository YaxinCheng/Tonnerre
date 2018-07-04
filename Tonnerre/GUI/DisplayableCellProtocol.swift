//
//  DIsplayableCellProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-15.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol DisplayableCellProtocol: class, ThemeProtocol {
  var view: NSView { get set }
  var iconView: TonnerreIconView! { get set }
  var serviceLabel: NSTextField! { get set }
  var introLabel: NSTextField! { get set }
  var highlighted: Bool { get set }
  var theme: TonnerreTheme { get set }
}

extension DisplayableCellProtocol {
  var highlighted: Bool {
    set {
      DispatchQueue.main.async { [weak self] in
        if newValue {
          self?.view.layer?.backgroundColor = self?.theme.highlightColour.cgColor
        } else {
          self?.view.layer?.backgroundColor = NSColor.clear.cgColor
        }
      }
    } get {
      return view.layer?.backgroundColor == theme.highlightColour.cgColor
    }
  }
}
