//
//  ExtWebServicesLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct ExtWebServicesLoader {
  static var nameToKeywords: [String: String] = [:]
  
  @objcMembers class ExtWebService: NSObject, TonnerreService, ExtendedWebService {
    var icon: NSImage {
      return storedImage ?? #imageLiteral(resourceName: "safari")
    }
    static var keyword: String {
      return ExtWebServicesLoader.nameToKeywords[self.className()] ?? ""
    }
    let argLowerBound: Int = 0
    let argUpperBound: Int = 0
    let name: String = ""
    let content: String = ""
    let template: String = ""
    let iconURL: String = ""
    internal var storedImage: NSImage? = nil
    
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
      let localeInTemplate = (type(of: self).keyword.components(separatedBy: "@").count - 1 - argLowerBound) == 1
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
    
    internal func loadImage() {
      let setupImage: (NSImage?)-> Void = { [weak self] in
        $0?.size = NSSize(width: 40, height: 40)
        self?.storedImage = $0
      }
      guard !iconURL.isEmpty else { return }
      if iconURL.starts(with: "https") {//web image
        guard let url = URL(string: iconURL) else { return }
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60 * 60 * 12)
        
        if let response = URLCache.shared.cachedResponse(for: request) {
          guard let image = NSImage(data: response.data) else { return }
          setupImage(image)
        } else {
          session.dataTask(with: request) { (data, response, error) in
            guard let imgData = data, let image = NSImage(data: imgData) else { return }
            setupImage(image)
            }.resume()
        }
      } else {//local file image
        let userDefault = UserDefaults.standard
        let appSupDir = userDefault.url(forKey: StoredKeys.appSupportDir.rawValue)!
        let desiredURL = URL(fileURLWithPath: iconURL, relativeTo: appSupDir)
        setupImage(NSImage(contentsOf: desiredURL))
      }
    }
  }
  
  private func constructInit(data: [Ivar: Any]) -> IMP {
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
      (SELF as? ExtendedWebService)?.loadImage()
      return SELF
    }
    return imp_implementationWithBlock(constructor)
  }
  
  private func buildIvarContent(fields: [String: Any]) -> [Ivar: Any] {
    var emptyDict: [Ivar: Any] = [:]
    for (field, value) in fields {
      guard
        let fieldBytes = (field as NSString).utf8String,
        let associatedIvar = class_getInstanceVariable(ExtWebService.self, fieldBytes)
      else { continue }
      emptyDict[associatedIvar] = value
    }
    return emptyDict
  }
  
  private func constructClass(name: String, content: [String: Any]) -> TonnerreService.Type? {
    guard
      let nameBytes = (name as NSString).utf8String,
      let Class = objc_allocateClassPair(ExtWebService.self, nameBytes, 0),
      let superConstructor = class_getClassMethod(ExtWebService.self, #selector(ExtWebService.init)),
      let constructorType = method_getTypeEncoding(superConstructor)
    else { return nil }
    let subConstructor = constructInit(data: buildIvarContent(fields: content))
    guard
      class_addMethod(Class, #selector(ExtWebService.init), subConstructor, constructorType),
      class_addProtocol(Class, ExtendedWebService.self)
    else { return nil }
    objc_registerClassPair(Class)
    ExtWebServicesLoader.nameToKeywords[(Class as! NSObject.Type).className()] = content["keyword"] as? String ?? name
    return Class as? TonnerreService.Type
  }
  
  func load() -> [TonnerreService.Type] {
    let appSupDir = UserDefaults.standard.url(forKey: StoredKeys.appSupportDir.rawValue)!
    let serviceJSON = appSupDir.appendingPathComponent("Services/webExt.json")
    guard
      let jsonData = try? Data(contentsOf: serviceJSON, options: .mappedIfSafe),
      let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: [String: Any]]
    else { return [] }
    return jsonObject.compactMap { constructClass(name: $0.key.capitalized.replacingOccurrences(of: " ", with: ""), content: $0.value) }
  }
}
