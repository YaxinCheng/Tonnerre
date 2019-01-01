//
//  Notification+Names.swift
//  TonnerreIndexHelper
//
//  Created by Yaxin Cheng on 2018-06-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension Notification.Name {
  static let documentIndexingDidFinish = Notification.Name("documentIndexingDidFinish")
  static let defaultIndexingDidFinish = Notification.Name("defaultIndexingDidFinish")
  static let helperAppDidExit = Notification.Name("helperAppDidExit")
}
