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
  
  func prepare(withInput input: [String], provider: TNEServiceProvider) -> [DisplayProtocol] {
    let urlTemplate = mainJSON["URLTemplate"] as! String
    if provider.argLowerBound == provider.argUpperBound && provider.argUpperBound == 0 {
      return [DisplayableContainer<URL>(name: provider.name, content: provider.content,
                                        icon: provider.icon, innerItem: URL(string: urlTemplate),
                                        placeholder: provider.keyword)]
    } else {
      let filledURL = urlTemplate.filled(arguments: input.compactMap {
        $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      }, separator: "+")
      return [DisplayableContainer<URL>(name: provider.name.filled(arguments: input)
        , content: provider.content.filled(arguments: input), icon: provider.icon
        , innerItem: URL(string: filledURL), placeholder: provider.keyword)]
    }
  }
  
  func execute(withArguments args: Arguments) throws -> JSON? {
    switch args {
    case .supply(input: let input):
      if let inputFormat = mainJSON["inputFormat"] as? String {
        let inputFmtRegex = try NSRegularExpression(pattern: inputFormat, options: .caseInsensitive)
        for query in input where query.match(regex: inputFmtRegex) == nil {
          throw TNEExecutor.Error.wrongInputFormatError(information:
            "The flight code is formed with 2 alphabets + 3~4 numbers")
        }
      }
      let urlTemplate: String = mainJSON["URLTemplate"]!
      let filledURL = urlTemplate.filled(arguments: input.compactMap {
        $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }, separator: "+")
      
      guard let nameTemplate: String = descJSON["name"]
        else { throw TNEExecutor.Error.missingAttribute("name", atPath: scriptPath) }
      guard let contentTemplate: String = descJSON["content"]
        else { throw TNEExecutor.Error.missingAttribute("content", atPath: scriptPath) }
      
      let name = nameTemplate.filled(arguments: input)
      let content = contentTemplate.filled(arguments: input)
      return [["name": name, "content": content, "innerItem": filledURL]]
    case .serve(choice: let choice):
      let rawURL = (choice["innerItem"] as? String) ?? mainJSON["URLTemplate"] as! String
      guard
        let url = URL(string: rawURL)
      else { return nil }
      NSWorkspace.shared.open(url)
      return nil
    }
  }
}
