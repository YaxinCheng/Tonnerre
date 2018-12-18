//
//  Switch.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-17.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol SwitchDelegate: class {
  func valueDidChange(sender: Any)
}

final class Switch: NSView {
  
  enum State {
    case on
    case off
    
    fileprivate func flipflop() -> State {
      switch self {
      case .on : return .off
      case .off: return .on
      }
    }
  }
  
  var state: State = .off {
    didSet {
      toggleSwitch()
      delegate?.valueDidChange(sender: self)
    }
  }
  
  var highlightColour: NSColor
  weak var delegate: SwitchDelegate?
  
  private let handleView: NSView
  private var handleViewLeadingConstraint: NSLayoutConstraint!
  
  required init?(coder decoder: NSCoder) {
    if #available(OSX 10.14, *) {
      highlightColour = .controlAccentColor
    } else {
      highlightColour = .blue
    }
    handleView = NSView()
    
    super.init(coder: decoder)
    
    setupHandleView()
    setupView()
  }
  
  private func setupHandleView() {
    handleView.wantsLayer = true
    handleView.translatesAutoresizingMaskIntoConstraints = false
    let handleXPosition = state == .off ? 0 : frame.width / 2
    handleView.layer?.backgroundColor = NSColor.gray.cgColor
    handleView.layer?.cornerRadius = frame.height / 2
    addSubview(handleView)
    handleViewLeadingConstraint = handleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: handleXPosition)
    NSLayoutConstraint.activate([
      handleViewLeadingConstraint,
      handleView.topAnchor.constraint(equalTo: topAnchor),
      handleView.bottomAnchor.constraint(equalTo: bottomAnchor),
      handleView.widthAnchor.constraint(equalTo: handleView.heightAnchor)
    ])
  }
  
  private func setupView() {
    wantsLayer = true
    layer?.cornerRadius = frame.height / 2
    layer?.borderWidth = 1
    layer?.borderColor = NSColor.gray.cgColor
  }
  
  override func mouseUp(with event: NSEvent) {
    state = state.flipflop()
  }
  
  private func toggleSwitch(animated: Bool = true) {
    let destinationX: CGFloat
    let backgroundColor: CGColor
    switch state {
    case .on:
      backgroundColor = highlightColour.cgColor
      destinationX = frame.width / 2
    case .off:
      backgroundColor = .clear
      destinationX = 0
    }
    NSAnimationContext.runAnimationGroup { [weak self] (context) in
      context.duration = 0.3
      self?.layer?.backgroundColor = backgroundColor
      self?.handleViewLeadingConstraint.animator().constant = destinationX
    }
  }
}
