//
//  CurrencyService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct CurrencyService: TonnerreService {
  let keyword: String = ""
  let icon: NSImage = #imageLiteral(resourceName: "calculator")
  let name: String = "Currency Exchange"
  let content: String = "Currency change from %@ to %@"
  let argLowerBound: Int = 2
  let argUpperBound: Int = 4
  let hasPreview: Bool = true
  let template: String = "https://free.currencyconverterapi.com/api/v5/convert?q=%@&compact=ultra"//USD_CAD,USD_JPY
  private let currencyCodes: Set<String>
  private let popularCurrency: [String] = ["USD", "EUR", "GBP", "JPY", "CHF", "CNY"]
  
  init() {
    currencyCodes = Set(Locale.isoCurrencyCodes)
  }
  
  private func gatherPopularCurrency(exclusion: [String]) -> [String] {
    var popular = [String]()
    for currency in popularCurrency {
      guard popular.count < 4 else { break }
      if !exclusion.contains(currency) {
        popular.append(currency)
      }
    }
    return popular
  }
  
  func prepare(input: [String]) -> [Displayable] {
    let number = Double(input[0]) ?? Double(input[1]) ?? 1
    let fromCurrency = (currencyCodes.contains(input[0].uppercased()) ? input[0] : input[1]).uppercased()
    guard currencyCodes.contains(fromCurrency) else { return [] }
    let toCurrency: String
    if input.count > 3 {
      toCurrency = (input[2].lowercased() == "to" ? input[3] : input[2]).uppercased()
    } else if input.count == 3 {
      toCurrency = currencyCodes.contains(input[2].uppercased()) ? input[2].uppercased() : ""
    } else { toCurrency = "" }
//    let popular = gatherPopularCurrency(exclusion: [fromCurrency, toCurrency])
//    let urlComponent = (popular + [toCurrency]).filter { !$0.isEmpty }
//      .map { "\(fromCurrency)_\($0)" }
//      .joined(separator: ",")
//    let url = URL(string: String(format: template, urlComponent))!
    return [DisplayableContainer<[String]>(name: "\(number) \(fromCurrency) ➡️ \(toCurrency)", content: String(format: content, fromCurrency, toCurrency), icon: icon, innerItem: [fromCurrency, toCurrency])]
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    
  }
}
