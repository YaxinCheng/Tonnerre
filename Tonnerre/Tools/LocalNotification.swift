//
//  LocalNotification.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import UserNotifications

struct LocalNotification {
  let title: String
  let content: String
  var muted: Bool = false
  
  func send() {
    let notification = UNMutableNotificationContent()
    notification.title = title
    notification.body = content
    notification.sound = muted ? nil : UNNotificationSound.default
    let request = UNNotificationRequest(identifier: title, content: notification, trigger: nil)
    let centre = UNUserNotificationCenter.current()
    centre.add(request, withCompletionHandler: nil)
  }
}
