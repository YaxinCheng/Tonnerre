//
//  TNEServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-31.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

/**
 Wraper class for TNE scripts
 */
final class TNEServices: TonnerreService {
  static let keyword: String = ""
  let argLowerBound: Int = 0
  let argUpperBound: Int = .max
  let icon: NSImage = #imageLiteral(resourceName: "tonnerre_extension")
  
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
  
  @available(*, deprecated: 6.0, message: "Prepare is replaced by functions in TNEInterpreter")
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    fatalError("Prepare is replaced by functions in TNEInterpreter")
  }
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
      let originalService: TNEScript
      if let urlResult = service as? DisplayableContainer<URL>,
        let service = urlResult.extraContent as? TNEScript {
        originalService = service
      } else if
        let anyResult = service as? DisplayableContainer<Any>,
        let service = anyResult.extraContent as? TNEScript {
        originalService = service
      } else if let appleScript = service as? TNEScript {
        originalService = appleScript
      } else { return }
      var dictionarizedChoice = self.dictionarize(service)
      dictionarizedChoice["withCmd"] = withCmd
      _ = originalService.execute(args: .serve(choice: dictionarizedChoice))
    }
  }
}

extension TNEServices: AsyncLoadingProtocol {
  var mode: AsyncLoadingType { return .replaced }
  
  func present(rawElements: [Any]) -> [ServicePack] {
    guard let sources = rawElements as? [DisplayProtocol] else { return [] }
    return sources.map { ServicePack(provider: self, service: $0) }
  }
}

