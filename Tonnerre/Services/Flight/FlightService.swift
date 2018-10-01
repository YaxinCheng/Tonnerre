//
//  FlightService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation
import Cocoa

struct FlightService: TonnerreService {
  static let keyword: String = "flight"
  let argLowerBound: Int = 1
  let argUpperBound: Int = 2// Do not why there will be a space
  let icon: NSImage = #imageLiteral(resourceName: "flight")
  let name: String = "Flight Checker"
  let content: String = "Check flight status for input flight number"
  private let rawURL = "https://www.flightstats.com/v2/flight-tracker/%@/%@"
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard let rawFlightCode = input.first else { return [] }
    if input.count == 2 && !input[1].isEmpty { return [] }
    let airlineCodePattern = try! NSRegularExpression(pattern: "[A-Za-z]{2,5}")
    let flightCodePattern  = try! NSRegularExpression(pattern: "\\d+")
    guard
      let airlineCodeSub = rawFlightCode.match(regex: airlineCodePattern),
      let airlineCode = Optional.some(String(airlineCodeSub)),
      let flightCodeString = rawFlightCode.match(regex: flightCodePattern),
      let flightCode  = UInt(flightCodeString),
      let viewController = FUFlightViewController(flightCode: flightCode, airlineCode: airlineCode),
      let url = URL(string: rawURL.filled(arguments: [airlineCode, String(flightCodeString)]))
    else { return [self] }
    return [DisplayableContainer<URL>(name: "Flight check for \"\(rawFlightCode)\"", content: "Press space or force touch to preview", icon: icon, innerItem: url, extraContent: viewController)]
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard
      let container = source as? DisplayableContainer<URL>,
      let url = container.innerItem
    else { return }
    NSWorkspace.shared.open(url)
  }
}
