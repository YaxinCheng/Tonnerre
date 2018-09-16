//
//  WebExtInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-15.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Interpreter provides WebExt services
 */
struct WebExtInterpreter: Interpreter {
  let loader: WebExtHub = .default
  
  func wrap(_ rawData: [WebExt], withTokens tokens: [String]) -> [ServicePack] {
    let webExtService = WebExtService()
    guard tokens.count > 1 else { return rawData.map { ServicePack(provider: webExtService, service: $0) } }
    let queryContent = Array(tokens[1...])
    var inRangedServices = rawData
      .filter { $0.argLowerBound <= queryContent.count && $0.argUpperBound >= queryContent.count }
    for (index, var service) in inRangedServices.enumerated() {
      service.content = service.content.filled(withArguments: queryContent)
      service.rawURL = service.rawURL.filled(withArguments: queryContent)
      inRangedServices[index] = service
    }
    return inRangedServices.map { ServicePack(provider: webExtService, service: $0) }
  }
}
