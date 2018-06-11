//
//  WebService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol WebService: TonnerreService {
  var template: String { get }
  var suggestionTemplate: String { get }
  var contentTemplate: String { get }
  var loadSuggestion: Bool { get }
  func encodedSuggestions(queries: [String]) -> [ServiceResult]
  func processJSON(data: Data?) -> [String: Any]
}

extension WebService {
  var localeInTemplate: Bool {
    let numOfFomatters = template.components(separatedBy: "%@").count - 1
    return numOfFomatters - argLowerBound == 1
  }
  
  var content: String {
    guard contentTemplate.contains("%@") else { return contentTemplate }
    return String(format: contentTemplate, "")
  }
  
  func fillInTemplate(input: [String]) -> URL? {
    let requestingTemplate: String
    if localeInTemplate {
      let locale = Locale.current
      let regionCode = locale.regionCode == "US" ? "com" : locale.regionCode
      let parameters = [regionCode ?? "com"] + [String](repeating: "%@", count: argLowerBound)
      requestingTemplate = String(format: template, arguments: parameters)
    } else {
      requestingTemplate = template
    }
    guard requestingTemplate.contains("%@") else { return URL(string: requestingTemplate) }
    let urlEncoded = input.compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed )}
    guard urlEncoded.count >= input.count else { return nil }
    let parameters = Array(urlEncoded[0 ..< argLowerBound - 1]) +
      [urlEncoded[(argLowerBound - 1)...].filter { !$0.isEmpty }.joined(separator: "+")]
    return URL(string: String(format: requestingTemplate, arguments: parameters))
  }
  
  /**
   When loaded suggestions arrive (by notification), use this function to encode them into Displayable items
   
   - parameter queries: loaded suggestion names (e.g. When input "D", suggestions may include ["donald trump", "diana"]
   - returns: Encoded suggestions
  */
  func encodedSuggestions(queries: [String]) -> [ServiceResult] {
    return queries.compactMap {
      guard let url = fillInTemplate(input: [$0]) else { return nil }
      let content = contentTemplate.contains("%@") ? String(format: contentTemplate, "'\($0)'") : contentTemplate
      return DisplayableContainer(name: $0, content: content.capitalized, icon: icon, innerItem: url)
      }.map {
      ServiceResult(service: self, value: $0)
     }
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    let workspace = NSWorkspace.shared
    workspace.open(request)
  }
  
  func prepare(input: [String]) -> [Displayable] {
    let queryURL = fillInTemplate(input: input)
    guard let url = queryURL else { return [] }
    let queryContent = input.joined(separator: " ").capitalized
    let content = contentTemplate.contains("%@") ? String(format: contentTemplate, "'\(queryContent)'") : contentTemplate
    guard argLowerBound != 0 else { return [DisplayableContainer(name: name, content: content, icon: icon, innerItem: url)] }
    let originalSearch = DisplayableContainer(name: queryContent, content: content, icon: icon, innerItem: url)
    guard !suggestionTemplate.isEmpty, loadSuggestion else { return [originalSearch] }
    let session = URLSession(configuration: .default)
    guard let query = input.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      return [originalSearch]
    }
    let suggestionPath = String(format: suggestionTemplate, arguments: [query])
    guard let suggestionURL = URL(string: suggestionPath) else { return [originalSearch] }
    session.dataTask(with: suggestionURL) { (data, response, error) in
      let processedData = self.processJSON(data: data)
      let notification = Notification(name: .suggestionDidFinish, object: nil, userInfo: processedData)
      NotificationCenter.default.post(notification)
      }.resume()
    return [originalSearch]
  }
}
