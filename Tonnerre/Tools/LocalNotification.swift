//
//  LocalNotification.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import UserNotifications

final class LocalNotification {
  private init () {}
  
  static func send(title: String, content: String, muted: Bool = false) {
    if #available(OSX 10.14, *) {
      let notification = UNMutableNotificationContent()
      notification.title = title
      notification.body = content
      notification.sound = muted ? nil : UNNotificationSound.default
      let request = UNNotificationRequest(identifier: title, content: notification, trigger: nil)
      let centre = UNUserNotificationCenter.current()
      centre.add(request, withCompletionHandler: nil)
    } else {
      // Fallback on earlier versions
      let notification = NSUserNotification()
      notification.title = title
      notification.informativeText = content
      if !muted { notification.soundName = NSUserNotificationDefaultSoundName }
      NSUserNotificationCenter.default.deliver(notification)
    }
  }
}
