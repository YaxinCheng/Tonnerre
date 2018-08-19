//
//  Notification+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-23.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension Notification.Name {
  static let asyncLoadingDidFinish = Notification.Name("asyncLoadingDidFinish")
  static let windowIsHiding = Notification.Name("windowIsHiding")
  static let helperAppDidExit = Notification.Name("helperAppDidExit")
}
