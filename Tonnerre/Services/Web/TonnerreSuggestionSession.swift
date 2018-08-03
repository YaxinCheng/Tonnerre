//
//  TonnerreSuggestionSession.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-21.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class TonnerreSuggestionSession {
  private static var instance: TonnerreSuggestionSession? = nil
  private static let lock = DispatchSemaphore(value: 1)
  
  static var shared: TonnerreSuggestionSession {
    lock.wait()
    if instance == nil {
      instance = TonnerreSuggestionSession()
    }
    lock.signal()
    return instance!
  }
  
  private let session: URLSession
  private var suggestionRequest: URLSessionDataTask? = nil
  private let queue: DispatchQueue
  
  private init() {
    session = URLSession(configuration: .default)
    queue = DispatchQueue.global(qos: .userInitiated)
  }
  
  func send(request: URLSessionDataTask, after seconds: Double = 0.7) {
    suggestionRequest?.cancel()
    suggestionRequest = request
    queue.asyncAfter(deadline: .now() + seconds) { [weak self] in
      TonnerreSuggestionSession.lock.wait()
      defer { TonnerreSuggestionSession.lock.signal() }
      guard
        self?.suggestionRequest != nil,
        self?.suggestionRequest?.state == .suspended
      else { return }
      self?.suggestionRequest?.resume()
      self?.suggestionRequest = nil
    }
  }
  
  private var asyncRequest: DispatchWorkItem? = nil
  
  func send(request: DispatchWorkItem, after second: Double = 0) {
    asyncRequest?.cancel()
    asyncRequest = request
    queue.asyncAfter(deadline: .now() + second) { [weak self] in
      TonnerreSuggestionSession.lock.wait()
      defer { TonnerreSuggestionSession.lock.signal() }
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
    if suggestionRequest != nil {
      suggestionRequest?.cancel()
      suggestionRequest = nil
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
