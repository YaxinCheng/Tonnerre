//
//  NonScrollView.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-09.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class NonScrollView: NSScrollView {
  override func scrollWheel(with event: NSEvent) {
    #if DEBUG
    super.scrollWheel(with: event)
    #else
    nextResponder?.scrollWheel(with: event)
    #endif
  }
}
