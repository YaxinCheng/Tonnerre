//
//  SettingView.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class SettingView: NSScrollView {
  
  private lazy var contentHeight: NSLayoutConstraint = {
    return documentView!.constraints.filter{ $0.identifier == "contentHeight" }.first!
  }()
  
  @IBOutlet weak var leftPanel: NSStackView!
  @IBOutlet weak var rightPanel: NSStackView!
  @IBOutlet weak var titleLabel: NSTextField!
  
  enum PanelSide {
    case left
    case right
  }
  
  private var leftHeight: CGFloat = 0
  private var rightHeight: CGFloat = 0
  
  func addSubview(_ view: NSView, side: PanelSide) {
    if side == .left {
      leftHeight += view.frame.height + 12
      leftPanel.addView(view, in: .top)
    } else if side == .right {
      rightHeight += view.frame.height + 12
      rightPanel.addView(view, in: .top)
    }
  }
  
  func adjustHeight() {
    let requiredHeight: CGFloat
    if leftHeight < rightHeight {
      requiredHeight = rightHeight + 48 + 37
    } else {
      requiredHeight = leftHeight + 48 + 23 + 57 + 16
    }
    contentHeight.constant = max(requiredHeight, 560)
  }
}
