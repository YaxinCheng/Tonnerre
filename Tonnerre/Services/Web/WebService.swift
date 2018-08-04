//
//  WebService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol WebService: TonnerreService, AsyncLoadingProtocol {
  var template: String { get }
  var suggestionTemplate: String { get }
  var contentTemplate: String { get }
  var loadSuggestion: Bool { get }
  /**
   When async-loaded suggestions arrive (by notification), use this function to encode them into Displayable items
   
   - parameter suggestions: loaded suggestion names (e.g. When input "D", suggestions may include ["donald trump", "diana"]
   - returns: Encoded suggestions
   */
  func present(suggestions: [Any]) -> [ServiceResult]
  func parse(suggestionData: Data?) -> [String: Any]
}

extension WebService {
  var mode: AsyncLoadingType {
    return .append
  }
  
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
  
  func present(suggestions: [Any]) -> [ServiceResult] {
    guard suggestions is [String] else { return [] }
    return (suggestions as! [String]).compactMap {
      let readableContent: String
      if $0.contains("&#"), let decodedData = $0.data(using: .utf8) {
        readableContent = (try? NSAttributedString(data: decodedData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil))?.string ?? $0
      } else {
        readableContent = $0.removingPercentEncoding ?? $0
      }
      guard let url = fillInTemplate(input: [readableContent]) else { return nil }
      let content = contentTemplate.contains("%@") ? String(format: contentTemplate, "'\(readableContent)'") : contentTemplate
      return DisplayableContainer(name: readableContent, content: content.capitalized, icon: icon, innerItem: url)
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
    guard !(input.first?.isEmpty ?? false), let url = queryURL else { return [self] }
    let queryContent = input.joined(separator: " ").capitalized
    let content = contentTemplate.contains("%@") ? String(format: contentTemplate, "'\(queryContent)'") : contentTemplate
    guard argLowerBound != 0 else { return [DisplayableContainer(name: name, content: content, icon: icon, innerItem: url)] }
    let originalSearch = DisplayableContainer(name: queryContent, content: content, icon: icon, innerItem: url)
    guard !suggestionTemplate.isEmpty, loadSuggestion else { return [originalSearch] }
    guard let query = input.joined(separator: " ").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      return [originalSearch]
    }
    let session = TonnerreSuggestionSession.shared
    let suggestionPath = String(format: suggestionTemplate, arguments: [query])
    guard let suggestionURL = URL(string: suggestionPath) else { return [originalSearch] }
    let request = URLRequest(url: suggestionURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60 * 60 * 1)
    let ongoingTask = session.dataTask(request: request) { (data, response, error) in
      if error != nil {
        #if DEBUG
        debugPrint(error!)
        #endif
        return
      }
      let processedData = self.parse(suggestionData: data)
      let notification = Notification(name: .suggestionDidFinish, object: self, userInfo: processedData)
      NotificationCenter.default.post(notification)
    }
    session.send(request: ongoingTask)
    return [originalSearch]
  }
}
