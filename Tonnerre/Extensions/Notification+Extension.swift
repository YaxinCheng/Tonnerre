//
//  Notification+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-23.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension Notification.Name {
  static let documentIndexingDidBegin = Notification.Name("documentIndexingDidBegin")
  static let documentIndexingDidFinish = Notification.Name("documentIndexingDidFinish")
  static let defaultIndexingDidBegin = Notification.Name("defaultIndexingDidBegin")
  static let defaultIndexingDidFinish = Notification.Name("defaultIndexingDidFinish")
  static let suggestionDidFinish = Notification.Name("suggestionDidFinish")
  static let windowIsHiding = Notification.Name("windowIsHiding")
}
