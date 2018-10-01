//
//  TNEInterpreter.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Interpreter provides TNE script services
 */
struct TNEInterpreter: Interpreter {
  let loader: TNEHub = .default
  private let asyncSession = TonnerreSession.shared
  
  func wrap(_ rawData: [TNEScript], withTokens tokens: [String]) -> [ServicePack] {
    let tneProvider = TNEServices()
    if tokens.count == 1 {
      return rawData.map { ServicePack(provider: tneProvider, service: $0) }
    }
    let queryContent = Array(tokens[1...])
    var filteredScripts = rawData.filter { $0.lowerBound <= tokens.count - 1 && queryContent.count - 1 <= $0.upperBound }
    let task = DispatchWorkItem {
      let content = filteredScripts.compactMap { $0.execute(args: .prepare(input: queryContent)) }.reduce([], +)
      guard content.count > 0 else { return }
      let notification = Notification(name: .asyncLoadingDidFinish, object: self, userInfo: ["rawElements": content])
      NotificationCenter.default.post(notification)
    }
    asyncSession.send(request: task)
    for (index, var service) in filteredScripts.enumerated() {
      service.content = service.content.filled(arguments: queryContent)
      filteredScripts[index] = service
    }
    return filteredScripts.map { ServicePack(provider: tneProvider, service: $0) }
  }
}
