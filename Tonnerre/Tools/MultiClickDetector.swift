//
//  MultiClickDetector.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-01-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

final class MultiClickDetector {
  let keyCode: UInt16
  let numberOfClicks: UInt8
  let duration: Double
  private var clickState: State = .waiting
  private var failedCallback: (()->())?
  private let queue = DispatchQueue(label: "MultiClickDetector.thread")
  
  init(keyCode: UInt16, numberOfClicks: UInt8, duration: Double = 0.35, failedCallback: (()->())? = nil) {
    self.keyCode = keyCode
    self.numberOfClicks = numberOfClicks
    self.duration = duration
    self.failedCallback = failedCallback
  }
  
  func setFailedCallback(_ callback: @escaping ()->()) {
    failedCallback = callback
  }
  
  func click() -> State {
    switch clickState {
    case .waiting, .completed:
      beginDetecting()
    case .ongoing(count: let count):
      incrementClickingCount(count: count)
    }
    return clickState
  }
  
  private func beginDetecting() {
    clickState = .ongoing(count: 1)
    queue.asyncAfter(deadline: .now() + duration) { [weak self] in
      self?.clickState = .waiting
      self?.failedCallback?()
    }
  }
  
  private func incrementClickingCount(count: UInt8) {
    let nextCount = count + 1
    if nextCount == numberOfClicks {
      clickState = .completed
    } else {
      clickState = .ongoing(count: nextCount)
    }
  }
}

extension MultiClickDetector {
  enum State {
    case completed
    case waiting
    case ongoing(count: UInt8)
  }
}
