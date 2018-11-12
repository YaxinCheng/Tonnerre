//
//  WebService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol WebService: BuiltInProvider {
  var template: String { get }
  var suggestionTemplate: String { get }
  var contentTemplate: String { get }
  func parse(suggestionData: Data?) -> [String]
}

extension WebService {
  private var session: TonnerreSession {
    return .shared
  }
  
  private var localeInTemplate: Bool {
    let numOfFomatters = template.components(separatedBy: "%@").count - 1
    return numOfFomatters - argLowerBound == 1
  }
  
  var content: String {
    guard contentTemplate.contains("%@") else { return contentTemplate }
    return String(format: contentTemplate, "")
  }
  
  private func fillInTemplate(input: [String]) -> URL? {
    let requestingTemplate: String
    if localeInTemplate {
      let locale: Locale = .current
      let regionCode = locale.regionCode == "US" ? "com" : locale.regionCode
      let parameters = [regionCode ?? "com"] + [String](repeating: "%@", count: argLowerBound)
      requestingTemplate = template.filled(arguments: parameters)
    } else {
      requestingTemplate = template
    }
    guard requestingTemplate.contains("%@") else { return URL(string: requestingTemplate) }
    let urlEncoded = input.compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed )}
    guard urlEncoded.count >= input.count else { return nil }
    let rawURL = requestingTemplate.filled(arguments: urlEncoded, separator: "+")
    return URL(string: rawURL)
  }
  
  func present(rawElements: [Any]) -> [ServicePack] {
    guard rawElements is [String] else { return [] }
    return (rawElements as! [String]).compactMap {
      let readableContent: String
      let htmlEncodeDetect = try! NSRegularExpression(pattern: "(&#\\d+;)+")
      let isHTMLEncoded = htmlEncodeDetect.numberOfMatches(in: $0, range: NSRange(location: 0, length: $0.count)) > 0
      if isHTMLEncoded, let decodedData = $0.data(using: .utf8) {
        readableContent = (try? NSAttributedString(data: decodedData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil))?.string ?? $0
      } else {
        readableContent = $0.removingPercentEncoding ?? $0
      }
      guard let url = fillInTemplate(input: [readableContent]) else { return nil }
      let content = contentTemplate.contains("%@") ? contentTemplate.filled(arguments: ["'\(readableContent)'"]) : contentTemplate
      return DisplayableContainer(name: readableContent, content: content, icon: icon, innerItem: url)
      }.map {
        ServicePack(provider: self, service: $0)
     }
  }
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    guard let request = (service as? DisplayableContainer<URL>)?.innerItem else { return }
    let workspace = NSWorkspace.shared
    workspace.open(request)
  }
  
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    let queryURL = fillInTemplate(input: input)
    guard !(input.first?.isEmpty ?? false), let url = queryURL else { return [self] }
    let queryContent = input.joined(separator: " ")
    let content = contentTemplate.contains("%@") ? contentTemplate.filled(arguments: ["'\(queryContent)'"]) : contentTemplate
    guard argLowerBound > 0 else { return [DisplayableContainer(name: name, content: content, icon: icon, innerItem: url)] }
    let originalSearch = DisplayableContainer(name: queryContent, content: content, icon: icon, innerItem: url)
    guard
      !suggestionTemplate.isEmpty,
      let query = input.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
      let suggestionURL = URL(string: suggestionTemplate.filled(arguments: [query]))
    else { return [originalSearch] }
    let request = URLRequest(url: suggestionURL, timeoutInterval: 60 * 60)
    let session = URLSession(configuration: .default)
    let lock = DispatchSemaphore(value: 0)
    var suggestions: [DisplayProtocol] = []
    session.dataTask(with: request) { (data, response, error) in
      if error != nil {
        #if DEBUG
        debugPrint(error!)
        #endif
        lock.signal()
        return
      }
      let lowerQuery = queryContent.lowercased()
      let processedData = self.parse(suggestionData: data).filter { $0.lowercased() != lowerQuery }
      suggestions = self.present(rawElements: processedData)
      lock.signal()
    }.resume()
    _ = lock.wait(timeout: .now() + 0.2)
    return [originalSearch] + suggestions
  }
}
