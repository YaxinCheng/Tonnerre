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
        NSLayoutConstraint.activate([(validCell as! NSView).widthAnchor.constraint(equalToConstant: 500)])
        return validCell
      }
    }
    return nil
  }
  
  var settingOptions: (left: [ViewController.SettingOption], right: [ViewController.SettingOption])!
  
  @IBOutlet var settingView: SettingView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    reload()
    settingView.postsBoundsChangedNotifications = true
    NotificationCenter.default.addObserver(forName: NSView.boundsDidChangeNotification, object: nil, queue: .main) { [unowned self] _ in
      let yPos = self.settingView.contentView.bounds.origin.y
      if yPos <= -(self.settingView.titleLabel.frame.height) {
        self.view.window?.title = self.settingView.titleLabel.stringValue
      } else {
        self.view.window?.title = ""
      }
    }
  }
  
  private func setupCell(with datasource: ViewController.SettingOption) -> NSView? {
    let cell = instantiateCell(withType: datasource.type)
    cell?.titleLabel.stringValue = datasource.title
    cell?.detailLabel.stringValue = datasource.detail
    cell?.settingKey = datasource.settingKey
    return cell as? NSView
  }
  
  func reload() {
    let leftViews = settingOptions.left.compactMap(setupCell)
    let rightViews = settingOptions.right.compactMap(setupCell)
    leftViews.forEach { settingView.addSubview($0, side: .left) }
    rightViews.forEach { settingView.addSubview($0, side: .right) }
    settingView.adjustHeight()
  }
}
