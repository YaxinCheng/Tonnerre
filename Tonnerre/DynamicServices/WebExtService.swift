//
//  WebExtService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class WebExtService: TonnerreService {
  static let keyword: String = ""
  let argLowerBound: Int = 0
  let argUpperBound: Int = .max
  var icon: NSImage {
    return #imageLiteral(resourceName: "tonnerre_extension").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  
  /**
   Fill in parameters into the given string template
   - parameter template: a template string with one ore multiple %@ as the placeholder
   - parameter args: arguments used to replace the placeholders
   - returns: a new string with the placeholders replaced by the arguments.
   
   - If the number of arguments is more than the number of placeholders, then the last a few arguments will be joined to one to fill one placeholder.
   - If the number of arguments is less than the number of placeholders, then the template will be returned without filling.
   */
  private func fill(template: String, withArguments args: [String]) -> String {
    let placeholderCount = template.components(separatedBy: "%@").count - 1
    guard placeholderCount <= args.count else { return template }
    if placeholderCount == args.count {
      return String(format: template, arguments: args)
    } else {
      let lastArg = args[placeholderCount...].joined(separator: " ")
      let fillInArgs = Array(args[..<placeholderCount]) + [lastArg]
      return String(format: template, arguments: fillInArgs)
    }
  }
  
  private var cachedKey: String?
  private var cachedService: [WebExt] = []
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard input.count > 0 else { return [] }
    let queryKey = input.first!.lowercased()
    if queryKey != cachedKey {
      cachedKey = queryKey
      cachedService = WebExtHub.default.find(keyword: queryKey)
        .filter { !UserDefaults.shared.bool(forKey: "\($0.id)+isDisabled") }
    }
    let possibleService = cachedService
    if input.count > 1 {
      let queryContent = Array(input[1...])
      let inRangedServices = possibleService.filter { $0.argLowerBound <= input.count && $0.argUpperBound >= input.count }
      for service in inRangedServices {
        service.content = fill(template: service.content, withArguments: queryContent)
        service.url = URL(string: fill(template: service.url.absoluteString, withArguments: queryContent))!
      }
      return inRangedServices
    }
    return possibleService
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let webExt = source as? WebExt else { return }
    let workspace = NSWorkspace.shared
    workspace.open(webExt.url)
  }
}
