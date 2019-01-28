//
//  MultiClickDetector.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-01-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class MultiClickDetector {
  let keyCode: UInt16
  let modifiers: NSEvent.ModifierFlags
  let numberOfClicks: UInt8
  let duration: Double
  private var clickState: State = .waiting
  private var failedCallback: (()->())?
  private let queue = DispatchQueue.main
  
  init(keyCode: UInt16, modifiers: NSEvent.ModifierFlags, numberOfClicks: UInt8, duration: Double = 0.35, failedCallback: (()->())? = nil) {
    self.keyCode = keyCode
    self.modifiers = modifiers
    self.numberOfClicks = numberOfClicks
    self.duration = duration
    self.failedCallback = failedCallback
  }
  
  func setFailedCallback(_ callback: @escaping ()->()) {
    failedCallback = callback
  }
  
  func click(_ event: NSEvent) -> State {
    guard
      event.keyCode == keyCode &&
      event.modifierFlags.contains(modifiers)
    else {
      clickState = .waiting
      return clickState
    }
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
