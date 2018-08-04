//
//  TonnerreSession.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-21.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class TonnerreSession {
  private static let lock = DispatchSemaphore(value: 1)
  
  /**
   Returns the shared instance of TonnerreSession
  */
  static let shared = TonnerreSession()
  
  private let session: URLSession
  private var URLDataTask: URLSessionDataTask? = nil
  private let queue: DispatchQueue
  
  private init() {
    session = URLSession(configuration: .default)
    queue = DispatchQueue.global(qos: .userInitiated)
  }
  
  func send(request: URLSessionDataTask, after seconds: Double = 0.7) {
    URLDataTask?.cancel()
    URLDataTask = request
    queue.asyncAfter(deadline: .now() + seconds) { [weak self] in
      TonnerreSession.lock.wait()
      defer { TonnerreSession.lock.signal() }
      guard
        self?.URLDataTask != nil,
        self?.URLDataTask?.state == .suspended
      else { return }
      self?.URLDataTask?.resume()
      self?.URLDataTask = nil
    }
  }
  
  private var asyncRequest: DispatchWorkItem? = nil
  
  func send(request: DispatchWorkItem, after second: Double = 0) {
    asyncRequest?.cancel()
    asyncRequest = request
    queue.asyncAfter(deadline: .now() + second) { [weak self] in
      TonnerreSession.lock.wait()
      defer { TonnerreSession.lock.signal() }
      guard
        self?.asyncRequest != nil,
        self?.asyncRequest?.isCancelled == false,
        self?.asyncRequest === request
      else { return }
      DispatchQueue.global(qos: .userInteractive).async(execute: request)
      self?.asyncRequest = nil
    }
  }
  
  func cancel() {
    if URLDataTask != nil {
      URLDataTask?.cancel()
      URLDataTask = nil
    }
    if asyncRequest != nil {
      asyncRequest?.cancel()
      asyncRequest = nil
    }
  }
  
  func dataTask(request: URLRequest, completionHanlder: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    return session.dataTask(with: request, completionHandler: completionHanlder)
  }
}
