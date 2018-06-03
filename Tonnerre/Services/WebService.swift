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
  var loadSuggestion: Bool { get }
  func suggest(queries: [String]) -> [ServiceResult]
  func processJSON(data: Data?) -> [String: Any]
}

extension WebService {
  func fillInTemplate(input: [String]) -> String {
    let urlEncoded = input.compactMap { $0.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed )}
    guard urlEncoded.count >= input.count else { return "" }
    let parameters = Array(urlEncoded[0 ..< arguments.count - 1]) +
      [urlEncoded[(arguments.count - 1)...].filter { !$0.isEmpty }.joined(separator: "+")]
    return String(format: template, arguments: parameters)
  }
  
  func suggest(queries: [String]) -> [ServiceResult] {
    return queries.map {
      WebRequest(name: $0, content: fillInTemplate(input: [$0]), icon: icon)
      }.map {
      ServiceResult(service: self, value: $0)
     }
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let url = URL(string: source.content) else { return }
    let workspace = NSWorkspace.shared
    workspace.open(url)
  }
  
  func prepare(input: [String]) -> [Displayable] {
    let queryURL = fillInTemplate(input: input)
    guard !queryURL.isEmpty else { return [] }
    let originalSearch = WebRequest(name: input.joined(separator: " "), content: queryURL, icon: icon)
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
