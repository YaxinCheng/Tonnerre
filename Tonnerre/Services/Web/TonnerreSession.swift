//
//  TonnerreSession.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-21.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class TonnerreSession {
  private let lock: DispatchSemaphore
  
  /**
   Returns the shared instance of TonnerreSession
  */
  static let shared = TonnerreSession()
  
  private let queue: DispatchQueue
  private var taskQueue: [DispatchWorkItem] = []
  
  init() {
    queue = DispatchQueue(label: "Tonnerre.Session.Queue", qos: .userInitiated, attributes: .concurrent)
    lock  = DispatchSemaphore(value: 1)
  }
  
  init(queue: DispatchQueue) {
    self.queue = queue
    lock = DispatchSemaphore(value: 1)
  }
  
  func enqueue(task: DispatchWorkItem, after second: Double = 0) {
    lock.wait()
    taskQueue.append(task)
    guard
      taskQueue.count != 0,
      taskQueue.first?.isCancelled == false
    else {
      lock.signal()
      return
    }
    let task = taskQueue.removeFirst()
    lock.signal()
    
    queue.asyncAfter(deadline: .now() + second, execute: task)
  }
  
  func cancel() {
    lock.wait()
    taskQueue.removeAll()
    lock.signal()
  }

}
