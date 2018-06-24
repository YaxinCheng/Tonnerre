//
//  ServiceResult.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

enum ServiceResult: Displayable {
  case service(origin: TonnerreService)
  case result(service: TonnerreService, value: Displayable)
  
  var icon: NSImage {
    switch self {
    case .service(origin: let value): return value.icon
    case .result(service: _, value: let value): return value.icon
    }
  }
  
  var name: String {
    switch self {
    case .service(origin: let value): return value.name
    case .result(service: _, value: let value): return value.name
    }
  }
  
  var content: String {
    switch self {
    case .service(origin: let value): return value.content
    case .result(service: _, value: let value): return value.content
    }
  }
  
  var itemIdentifier: NSUserInterfaceItemIdentifier {
    switch self {
    case .service(origin: let value): return value.itemIdentifier
    case .result(service: let service, value: _): return service.itemIdentifier
    }
  }
  
  init(service: TonnerreService) {
    self = .service(origin: service)
  }
  
  init(service: TonnerreService, value: Displayable) {
    self = .result(service: service, value: value)
  }
}
