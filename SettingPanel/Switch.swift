//
//  Switch.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-08-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa
import Lottie

protocol SwitchDelegate: class {
  func valueChanged(sender: Switch)
}

final class Switch: LOTAnimationView {
  enum State: CGFloat {
    case off = 0.5
    case on = 0
    
    static prefix func !(value: State) -> State {
      if value == .on { return .off }
      else { return .on }
    }

    init(rawValue: CGFloat) {
      if rawValue - 0.25 <= 0.0001 {
        self = .on
      } else {
        self = .off
      }
    }
  }
  
  weak var delegate: SwitchDelegate?
  var state: State {
    set {
      play(fromProgress: animationProgress, toProgress: newValue.rawValue, withCompletion: nil)
    } get {
      return State(rawValue: animationProgress)
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    state = !state
    delegate?.valueChanged(sender: self)
  }
  
  /**
   The point where dragging starts
  */
  private var beginPoint: NSPoint!
  
  override func mouseDown(with event: NSEvent) {
    beginPoint = event.locationInWindow
  }
  
  override func mouseDragged(with event: NSEvent) {
    let currentPoint = event.locationInWindow
    if currentPoint.x - beginPoint.x <= 0 {
      state = .off
    } else {
      state = .on
    }
    beginPoint = currentPoint
  }
}
