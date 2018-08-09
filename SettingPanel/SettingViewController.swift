//
//  SettingViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class SettingViewController: NSViewController {
  
  private static var cells: [SettingCellType: SettingCell] = {
    var cellArray: NSArray?
    var tempDict = [SettingCellType: SettingCell]()
    guard
      let nib = NSNib(nibNamed: .settingCell, bundle: .main),
      nib.instantiate(withOwner: self, topLevelObjects: &cellArray)
      else { fatalError("Nib cannot be initialized") }
    for controller in cellArray ?? [] {
      if let validCell = (controller as? NSViewController)?.view as? SettingCell {
        tempDict[validCell.type] = validCell
      }
    }
    return tempDict
  }()
  
  var settingOptions: (left: [SettingCellType], right: [SettingCellType])! {
    didSet {
      // adjust the height of scroll contentView
      
    }
  }
  
  @IBOutlet var settingView: SettingView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    reload()
  }
  
  func reload() {
    let leftViews = settingOptions.left.compactMap { type(of: self).cells[$0]?.copy() as? NSView }
    let rightViews = settingOptions.right.compactMap { type(of: self).cells[$0]?.copy() as? NSView }
    leftViews.forEach { settingView.addSubview($0, side: .left) }
    rightViews.forEach { settingView.addSubview($0, side: .right) }
  }
}
