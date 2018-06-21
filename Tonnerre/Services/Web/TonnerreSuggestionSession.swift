//
//  TonnerreSuggestionSession.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-21.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

class TonnerreSuggestionSession {
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
      guard
        self?.suggestionRequest != nil,
        self?.suggestionRequest?.state == .suspended
      else { return }
      self?.suggestionRequest?.resume()
      TonnerreSuggestionSession.lock.signal()
    }
  }
  
  func cancel() {
    suggestionRequest?.cancel()
  }
  
  func dataTask(request: URLRequest, completionHanlder: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    return session.dataTask(with: request, completionHandler: completionHanlder)
  }
}
