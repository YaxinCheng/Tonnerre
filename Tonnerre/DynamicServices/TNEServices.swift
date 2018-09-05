//
//  TNEServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class TNEServices: TonnerreService {
  static let keyword: String = ""
  let argLowerBound: Int = 0
  let argUpperBound: Int = .max
  var icon: NSImage {
    return #imageLiteral(resourceName: "tonnerre_extension").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  private let asyncSession: TonnerreSession = .shared
  
  private var cachedKey: String?
  private var cachedServices: [TNEScript] = []
  
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
  
  private func dictionarize(_ displayItem: DisplayProtocol) -> Dictionary<String, Any> {
    let unwrap: (Any) -> Any = {
      let mirror = Mirror(reflecting: $0)
      guard
        mirror.displayStyle == .optional,
        let value = mirror.children.first
        else { return $0 }
      return value.value
    }
    let requiredKeys: Set<String> = ["name", "content", "innerItem"]
    return Dictionary(uniqueKeysWithValues:
      Mirror(reflecting: displayItem).children
        .filter { requiredKeys.contains(($0.label ?? "")) }
        .map { ($0.label!, $0.value as? String ?? String(reflecting: unwrap($0.value))) }
    )
  }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard input.count > 0 else { return [] }
    let queryKey = input.first!.lowercased()
    if cachedKey != queryKey {
      cachedKey = queryKey
      cachedServices = TNEHub.default.find(keyword: queryKey)
    }
    let possibleServices = cachedServices
    if input.count > 1 {
      let queryContent = Array(input[1...])
      let task = DispatchWorkItem { [unowned self] in
        let content = possibleServices.compactMap { $0.execute(mode: .prepare(input: queryContent)) }.reduce([], +)
        guard content.count > 0 else { return }
        let notification = Notification(name: .asyncLoadingDidFinish, object: self, userInfo: ["rawElements": content])
        NotificationCenter.default.post(notification)
      }
      asyncSession.send(request: task)
      for service in possibleServices {
        service.content = fill(template: service.content, withArguments: queryContent)
      }
    }
    return possibleServices
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
      let originalService: TNEScript
      if let urlResult = source as? DisplayableContainer<URL>,
        let service = urlResult.extraContent as? TNEScript {
        originalService = service
      } else if
        let anyResult = source as? DisplayableContainer<Any>,
        let service = anyResult.extraContent as? TNEScript {
        originalService = service
      } else { return }
      var dictionarizedChoice = self.dictionarize(source)
      dictionarizedChoice["withCmd"] = withCmd
      _ = originalService.execute(mode: .serve(choice: dictionarizedChoice))
    }
  }
}

extension TNEServices: AsyncLoadingProtocol {
  func present(rawElements: [Any]) -> [ServicePack] {
    guard rawElements is [DisplayProtocol] else { return [] }
    return (rawElements as! [DisplayProtocol]).map { ServicePack(provider: self, service: $0) }
  }
  
  var mode: AsyncLoadingType { return .replaced }
  
}
