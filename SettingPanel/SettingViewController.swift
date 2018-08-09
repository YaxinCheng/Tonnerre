//
//  SettingViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class SettingViewController: NSViewController {
  
  func instantiateCell(withType type: SettingCellType) -> SettingCell? {
    var cellArray: NSArray?
    guard
      let nib = NSNib(nibNamed: .settingCell, bundle: .main),
      nib.instantiate(withOwner: self, topLevelObjects: &cellArray)
    else { fatalError("Nib cannot be initialized") }
    for controller in cellArray ?? [] {
      if let validCell = (controller as? NSViewController)?.view as? SettingCell,
        validCell.type == type {
        return validCell
      }
    }
    return nil
  }
  
  var settingOptions: (left: [ViewController.SettingOption], right: [ViewController.SettingOption])! {
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
  
  private func setupCell(with datasource: ViewController.SettingOption) -> NSView? {
    let cell = instantiateCell(withType: datasource.type)
    cell?.titleLabel.stringValue = datasource.title
    cell?.detailLabel.stringValue = datasource.detail
    return cell as? NSView
  }
  
  func reload() {
    let leftViews = settingOptions.left.compactMap(setupCell)
    let rightViews = settingOptions.right.compactMap(setupCell)
    leftViews.forEach { settingView.addSubview($0, side: .left) }
    rightViews.forEach { settingView.addSubview($0, side: .right) }
  }
}
