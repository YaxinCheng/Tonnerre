//
//  TabViewSegue.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TabViewSegue: NSStoryboardSegue {
  override func perform() {
    let contentController = sourceController as! SplitViewController
    contentController.contentView.subviews.removeAll()
    contentController.present(destinationController as! NSViewController, animator: TabViewAnimator())
  }
}
