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
  private var taskQueue: [DispatchWorkItem] = [] {
    didSet {
      var task: DispatchWorkItem! = nil
      while taskQueue.count > 0 {
        task = taskQueue.removeFirst()
        if !task.isCancelled { break }
      }
      lock.signal()
      guard task != nil else { return }
      queue.async(execute: task)
    }
  }
  
  private init() {
    queue = DispatchQueue(label: "Tonnerre.Session.Queue", qos: .userInteractive, attributes: .concurrent)
    lock  = DispatchSemaphore(value: 1)
  }
  
  init(queue: DispatchQueue) {
    self.queue = queue
    lock = DispatchSemaphore(value: 1)
  }
  
  func enqueue(task: DispatchWorkItem) {
    lock.wait()
    taskQueue.append(task)
  }
  
  func cancel() {
    lock.wait()
    taskQueue.removeAll()
  }

}
