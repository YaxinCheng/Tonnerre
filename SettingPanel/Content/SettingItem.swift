//
//  SettingItem.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-02.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol SettingItem {
  /// the key that locates the preference in the UserDefault
  /// - note: when the key is nil, this item is only for display
  var settingKey: String? { get }
  /// the name that will be displayed on the setting cell
  var name: String { get }
  /// The content that will be displayed below the name on a setting cell
  var content: String { get }
  /// Configurate the displayCell to display related information of this item
  /// - parameter displayCell: the cell that will be used to display this item
  func configure(displayCell: SettingCell)
  /// the identifier used to create certain type of setting item cell
  var displayIdentifier: NSUserInterfaceItemIdentifier { get }
}

extension SettingItem {
  var attributedName: NSAttributedString {
    return NSAttributedString(string: name, attributes: [.font:
      NSFont.systemFont(ofSize: 20, weight: .heavy)])
  }
  
  var attributedContent: NSAttributedString {
    return NSAttributedString(string: content, attributes: [.font:
      NSFont.systemFont(ofSize: 13)])
  }
}
