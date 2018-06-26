//
//  ExtWebServicesLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class ExtWebServicesLoader {
  @objcMembers class ExtWebService: NSObject, TonnerreService {
    var icon: NSImage {
      return storedImage ?? #imageLiteral(resourceName: "safari")
    }
    static var keyword: String = ""
    let argLowerBound: Int = 0
    let argUpperBound: Int = 0
    let name: String = ""
    let content: String = ""
    let template: String = ""
    var storedImage: NSImage? = nil
    
    func prepare(input: [String]) -> [Displayable] {
      guard let url = fillInTemplate(input: input) else { return [] }
      return [DisplayableContainer(name: name, content: fill(content: content, input: input), icon: icon, innerItem: url)]
    }
    
    func serve(source: Displayable, withCmd: Bool) {
      guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
      let workspace = NSWorkspace.shared
      workspace.open(request)
    }
    
    required override init() {
      super.init()
    }
    
    private func fillInTemplate(input: [String]) -> URL? {
      let requestingTemplate: String
      let localeInTemplate = (ExtWebServicesLoader.ExtWebService.keyword.components(separatedBy: "@").count - 1 - argLowerBound) == 1
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
    
    private func fill(content: String, input: [String]) -> String {
      guard content.contains("%@") else { return content }
      return String(format: content, arguments: input)
    }
  }
  
  private func constructInit(data: [Ivar: Any]) -> (@convention(block) (AnyObject, Selector)->AnyObject) {
    let constructor: (@convention(block) (AnyObject, Selector)->AnyObject) = { SELF, _ in
      for (attr, value) in data {
        let offSet = ivar_getOffset(attr)
        let base = unsafeBitCast(SELF, to: UnsafeMutableRawPointer.self)
        let ivarLocation = base.assumingMemoryBound(to: CUnsignedChar.self).advanced(by: offSet)
        if let intValue = value as? Int {
          ivarLocation.withMemoryRebound(to: Int.self, capacity: 1) {
            $0.pointee = intValue
          }
        } else if let stringValue = value as? String {
          ivarLocation.withMemoryRebound(to: String.self, capacity: 1) {
            $0.pointee = stringValue
          }
        }
      }
      return SELF
    }
    return constructor
  }
  
  
}
