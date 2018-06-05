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
  func suggest(queries: [String]) -> [ServiceResult]
  func processJSON(data: Data?) -> [String: Any]
}

extension WebService {
  var content: String {
    guard contentTemplate.contains("%@") else { return contentTemplate }
    return String(format: contentTemplate, "")
  }
  
  func fillInTemplate(input: [String]) -> URL? {
    let urlEncoded = input.compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed )}
    guard urlEncoded.count >= input.count else { return nil }
    let parameters = Array(urlEncoded[0 ..< arguments.count - 1]) +
      [urlEncoded[(arguments.count - 1)...].filter { !$0.isEmpty }.joined(separator: "+")]
    return URL(string: String(format: template, arguments: parameters))
  }
  
  func suggest(queries: [String]) -> [ServiceResult] {
    return queries.compactMap {
      guard let url = fillInTemplate(input: [$0]) else { return nil }
      let content = contentTemplate.contains("%@") ? String(format: contentTemplate, "'\($0)'") : contentTemplate
      return WebRequest(name: $0, content: content.capitalized, url: url, icon: icon)
      }.map {
      ServiceResult(service: self, value: $0)
     }
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = source as? WebRequest else { return }
    let workspace = NSWorkspace.shared
    workspace.open(request.innerURL)
  }
  
  func prepare(input: [String]) -> [Displayable] {
    let queryURL = fillInTemplate(input: input)
    guard let url = queryURL else { return [] }
    let queryContent = input.joined(separator: " ").capitalized
    let content = contentTemplate.contains("%@") ? String(format: contentTemplate, "'\(queryContent)'") : contentTemplate
    let originalSearch = WebRequest(name: queryContent, content: content, url: url, icon: icon)
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
