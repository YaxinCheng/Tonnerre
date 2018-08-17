//
//  NSUserNotification+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-16.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension NSUserNotification {
  static func send(title: String?, informativeText: String?, muted: Bool = true) {
    let notification = NSUserNotification()
    notification.title = title
    notification.informativeText = informativeText
    if !muted { notification.soundName = NSUserNotificationDefaultSoundName }
    NSUserNotificationCenter.default.deliver(notification)
  }
}
