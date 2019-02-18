//
//  TonnerreSession.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-21.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class TonnerreSession {
  private let enqueueLock: DispatchSemaphore
  
  /**
   Returns the shared instance of TonnerreSession
  */
  static let shared = TonnerreSession()
  
  private let queue: DispatchQueue
  private var taskQueue: [(DispatchWorkItem, Double)] = [] {
    didSet {
      var task: DispatchWorkItem! = nil
      var time: Double = 0
      while taskQueue.count > 0 {
        let dequeued = taskQueue.removeFirst()
        task = dequeued.0
        time = dequeued.1
        if !task.isCancelled { break }
      }
      guard task != nil && !task.isCancelled else { return }
      queue.asyncAfter(deadline: .now() + time) { [unowned self] in
        guard task != nil && !task.isCancelled else { return }
        self.queue.async(execute: task)
      }
    }
  }
  
  private init() {
    queue = DispatchQueue(label: "Tonnerre.Session.Queue", qos: .userInteractive, attributes: .concurrent)
    enqueueLock  = DispatchSemaphore(value: 1)
  }
  
  init(queue: DispatchQueue) {
    self.queue = queue
    enqueueLock = DispatchSemaphore(value: 1)
  }
  
  func enqueue(task: DispatchWorkItem, waitTime: Double = 0) {
    enqueueLock.wait()
    taskQueue.append((task, waitTime))
    enqueueLock.signal()
  }
  
  func cancel(task: DispatchWorkItem) {
    task.cancel()
  }
  
  func cancelAll() {
    enqueueLock.wait()
    taskQueue.forEach { $0.0.cancel() }
    taskQueue.removeAll()
    enqueueLock.signal()
  }
}
