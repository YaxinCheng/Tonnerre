//
//  WebService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-03.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

/// All providers connects to web and provider services should implements this protocol
protocol WebService: BuiltInProvider {
  /// The URL template used for the service
  ///
  /// e.g. https://google.ca/search?q=%@
  var template: String { get }
  /// The suggestion URL template
  ///
  /// Suggestion provides search suggestions asynchronizingly
  /// based on the given search terms
  var suggestionTemplate: String { get }
  /// The template for service contents
  var contentTemplate: String { get }
  /// Parse binary typed data into suggestion strings
  /// - parameter suggestionData: the binary typed data loaded from requesting
  ///                 the suggestion url
  /// - returns: an array of string suggestions
  func parse(suggestionData: Data?) -> [String]
}

extension WebService {
  private var session: TonnerreSession {
    return .shared
  }
  
  var content: String {
    return contentTemplate.filled(arguments: "")
  }
  
  var template: String {
    return WebServiceList.shared[self, .serviceTemplate]
  }
  
  var suggestionTemplate: String {
    return WebServiceList.shared[self, .suggestionsTemplate]
  }
  
  func encodedURL(input: [String]) -> URL? {
    let urlEncoded = input.compactMap {
      $0.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed.symmetricDifference(["&"]))
    }
    return URL(string: template.filled(arguments: urlEncoded, separator: "+"))
  }
  
  private func present(suggestion: String) -> DisplayItem? {
    let readableContent: String
    let htmlEncodeDetect = try! NSRegularExpression(pattern: "(&#\\d+;)+")
    let isHTMLEncoded = htmlEncodeDetect.numberOfMatches(in: suggestion,
                                                         range: NSRange(location: 0, length: suggestion.count)) > 0
    if isHTMLEncoded, let decodedData = suggestion.data(using: .utf8) {
      readableContent = (try? NSAttributedString(data: decodedData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil))?.string ?? suggestion
    } else {
      readableContent = suggestion.removingPercentEncoding ?? suggestion
    }
    guard let url = encodedURL(input: [readableContent]) else { return nil }
    let content = contentTemplate.filled(arguments: "\(readableContent)")
    return DisplayContainer(name: readableContent, content: content, icon: icon, innerItem: url)
  }
  
  func serve(service: DisplayItem, withCmd: Bool) {
    guard let request = (service as? DisplayContainer<URL>)?.innerItem else { return }
    let workspace = NSWorkspace.shared
    workspace.open(request)
  }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    let queryURL = encodedURL(input: input)
    guard !(input.first?.isEmpty ?? false), let url = queryURL else { return [self] }
    let content = contentTemplate.filled(arguments: input)
    guard argLowerBound > 0 else { return [DisplayContainer(name: name, content: content, icon: icon, innerItem: url)] }
    let originalSearch = DisplayContainer(name: input.joined(separator: " "), content: content, icon: icon, innerItem: url)
    return [originalSearch]
  }
  
  func supply(withInput input: [String], callback: @escaping ([DisplayItem])->Void) {
    let queryContent = input.joined(separator: " ")
    guard
      !suggestionTemplate.isEmpty,
      let query = queryContent.addingPercentEncoding(withAllowedCharacters:
        CharacterSet.urlQueryAllowed.symmetricDifference(["&"])),
      let suggestionURL = URL(string: suggestionTemplate.filled(arguments: query))
    else {
      callback([])
      return
    }
    let request = URLRequest(url: suggestionURL, timeoutInterval: 60 * 60)
    let session = URLSession(configuration: .default)
    session.dataTask(with: request) { (data, response, error) in
      if error != nil {
        #if DEBUG
        debugPrint(error!)
        #endif
        let errorItem = DisplayContainer(name: "Error at \(Self.self)", content: "\(error!)", icon: self.icon, innerItem: error!, placeholder: "")
        callback([errorItem])
        return
      }
      let suggestions = NSMutableArray()
      let lowerQuery = queryContent.lowercased()
      let processedData = self.parse(suggestionData: data).filter { $0.lowercased() != lowerQuery }
      let parsedSuggestions = processedData.compactMap(self.present)
      suggestions.addObjects(from: parsedSuggestions)
      callback(suggestions as? [DisplayItem] ?? [])
    }.resume()
  }
}
