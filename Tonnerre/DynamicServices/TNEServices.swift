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
    if input.count == 1 { return cachedServices }
    else {
      let queryContent = Array(input[1...])
      var possibleServices = cachedServices.filter { $0.lowerBound <= queryContent.count + 1 && $0.upperBound >= queryContent.count }
      let task = DispatchWorkItem { [unowned self] in
        let content = possibleServices.compactMap { $0.execute(args: .prepare(input: queryContent)) }.reduce([], +)
        guard content.count > 0 else { return }
        let notification = Notification(name: .asyncLoadingDidFinish, object: self, userInfo: ["rawElements": content])
        NotificationCenter.default.post(notification)
      }
      asyncSession.send(request: task)
      for (index, var service) in possibleServices.enumerated() {
        service.content = service.content.filled(withArguments: queryContent)
        possibleServices[index] = service
      }
      return possibleServices
    }
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
      _ = originalService.execute(args: .serve(choice: dictionarizedChoice))
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
