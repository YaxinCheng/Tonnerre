//
//  JSONExecutor.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct JSONExecutor: TNEExecutor {
  
  private let mainJSON: JSON
  private let descJSON: JSON
  let scriptPath: URL
  
  init?(scriptPath: URL) {
    self.scriptPath = scriptPath
    let mainScript = scriptPath.appendingPathComponent("main.json")
    let descriptJSONURL = scriptPath.appendingPathComponent("description.json")
    guard
      let mainJSONData = try? Data(contentsOf: mainScript),
      let mainJSON = JSON(data: mainJSONData),
      (mainJSON["URLTemplate"] as? String)?.starts(with: "http") == true,
    
      let descJSONData = try? Data(contentsOf: descriptJSONURL),
      let descJSON = JSON(data: descJSONData)
    else { return nil }
    self.mainJSON = mainJSON
    self.descJSON = descJSON
  }
  
  func prepare(withInput input: [String], provider: TNEServiceProvider) -> DisplayItem {
    let urlTemplate = mainJSON["URLTemplate"] as! String
    if let inputFormat = mainJSON["inputFormat"] as? String {
      do {
        let inputFmtRegex = try NSRegularExpression(pattern: inputFormat, options: .caseInsensitive)
        for query in input where (query.match(regex: inputFmtRegex) == nil) {
          return DisplayContainer<Error>(name: provider.name, content: "Wrong format: input must be in format of: \(inputFormat)",
                                              icon: provider.icon, innerItem:
                                              Error.wrongInputFormatError(information: "Input must be in format of: \(inputFormat)")
                                              , placeholder: provider.keyword)
        }
      } catch {
      }
    }
    if provider.argLowerBound == provider.argUpperBound && provider.argUpperBound == 0 {
      return DisplayContainer<URL>(name: provider.name, content: provider.content,
                                        icon: provider.icon, innerItem: URL(string: urlTemplate),
                                        placeholder: provider.keyword)
    } else {
      let filledURL = urlTemplate.filled(arguments: input.compactMap {
        $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      }, separator: "+")
      return DisplayContainer<URL>(name: provider.name.filled(arguments: input)
        , content: provider.content.filled(arguments: input), icon: provider.icon
        , innerItem: URL(string: filledURL), placeholder: provider.keyword)
    }
  }
  
  func execute(withArguments args: Arguments) throws -> JSON? {
    switch args {
    case .supply(input: _): break
    case .serve(choice: let choice):
      let rawURL = (choice["innerItem"] as? String) ?? mainJSON["URLTemplate"] as! String
      guard
        let url = URL(string: rawURL)
      else { return nil }
      NSWorkspace.shared.open(url)
    }
    return nil
  }
}
