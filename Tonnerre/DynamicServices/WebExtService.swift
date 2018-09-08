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
      var inRangedServices = possibleService
          .filter { $0.argLowerBound <= queryContent.count && $0.argUpperBound >= queryContent.count }
      for (index, var service) in inRangedServices.enumerated() {
        service.content = service.content.filled(withArguments: queryContent)
        service.rawURL = service.rawURL.filled(withArguments: queryContent)
        inRangedServices[index] = service
      }
      return inRangedServices
    }
    return possibleService
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard
      let webExt = source as? WebExt,
      let url = URL(string: webExt.rawURL)
    else { return }
    let workspace = NSWorkspace.shared
    workspace.open(url)
  }
}
