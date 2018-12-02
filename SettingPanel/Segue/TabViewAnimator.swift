//
//  TabViewAnimator.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-06.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TabViewAnimator: NSObject, NSViewControllerPresentationAnimator {
  func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
    
  }
  
  func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
    viewController.view.wantsLayer = true
    viewController.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
    
    (fromViewController as! SplitViewController).contentView.addSubview(viewController.view)
    let frame = fromViewController.view.frame
    viewController.view.frame = frame
  }
}
