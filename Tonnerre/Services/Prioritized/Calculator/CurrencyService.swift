//
//  CurrencyService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-11.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct CurrencyService: TonnerreService {
  static let keyword: String = ""
  let icon: NSImage = #imageLiteral(resourceName: "calculator")
  let name: String = "Currency Exchange"
  let content: String = "Currency change from %@ to %@"
  let argLowerBound: Int = 2
  let argUpperBound: Int = 4
  let template: String = "https://free.currencyconverterapi.com/api/v5/convert?q=%@&compact=ultra"//USD_CAD,USD_JPY
  private let currencyCodes: Set<String>
  private let popularCurrencies = ["USD", "EUR", "GBP", "JPY", "CHF", "CNY"]
  
  init() {
    currencyCodes = Set(Locale.isoCurrencyCodes)
  }
  
  func prepare(input: [String]) -> [Displayable] {
    let number = Double(input[0]) ?? Double(input[1]) ?? 1
    let fromCurrency = (currencyCodes.contains(input[0].uppercased()) ? input[0] : input[1]).uppercased()
    guard currencyCodes.contains(fromCurrency) else { return [] }
    let toCurrency: String
    if input.count == 2 && fromCurrency == input[0].uppercased() {
      toCurrency = (Double(input[1]) == nil ? input[1] : "").uppercased()
    } else if input.count == 3 {
      toCurrency = currencyCodes.contains(input[2].uppercased()) ? input[2].uppercased() : ""
    } else if input.count > 3 {
      toCurrency = (input[2].lowercased() == "to" ? input[3] : input[2]).uppercased()
    } else { toCurrency = "" }
    // The async function to setup the view
    let label = "\(number) \(fromCurrency) = %@ "
    let viewSetupGenerator: (String, String, String) -> ((ServiceCell) -> Void)? = { fromCurrency, toCurrency, label in
      if !self.currencyCodes.contains(fromCurrency) || !self.currencyCodes.contains(toCurrency) { return nil }
      return { cell in
          let key = [fromCurrency, toCurrency].joined(separator: "_")
          let url = URL(string: String(format: self.template, key))!
          let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60 * 30)
          URLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
            guard
              let jsonData = data,
              let jsonObj = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: Double],
              let rate = jsonObj[key]
            else { return }
            DispatchQueue.main.async {
              cell.serviceLabel.stringValue = String(format: label, "\(rate * number)")
            }
          }.resume()
      }
    }
    let populars = popularCurrencies.filter { $0 != fromCurrency && $0 != toCurrency }
    return ([toCurrency] + populars).map {
      let asyncViewSetup = viewSetupGenerator(fromCurrency, $0, label + $0)
      return AsyncedDisplayableContainer(name: String(format: label + $0, "..."), content: String(format: content, fromCurrency, $0), icon: icon, innerItem: [fromCurrency, $0], viewSetup: asyncViewSetup)
    }
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let innerItem = (source as? AsyncedDisplayableContainer<[String]>)?.innerItem else { return }
    let encoded = innerItem.joined(separator: "+")
    let url = URL(string: "https://google.com/search?q=\(encoded)")!
    NSWorkspace.shared.open(url)
  }
}
