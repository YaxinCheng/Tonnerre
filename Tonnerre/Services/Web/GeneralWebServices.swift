//
//  GeneralWebServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-04.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class GeneralWebService: TonnerreExtendService {
  let keyword: String
  let argLowerBound: Int
  let argUpperBound: Int
  let name: String
  let content: String
  let template: String
  let iconURL: String
  private var storedImage: NSImage? = nil
  var icon: NSImage {
    return storedImage ?? #imageLiteral(resourceName: "safari")
  }
  
  enum CodingKeys: String, CodingKey {
    case name
    case content//optional
    case keyword
    case template
    case argLowerBound
    case iconURL = "icon"
    case argUpperBound
  }
  
  func fillInTemplate(input: [String]) -> URL? {
    let requestingTemplate: String
    let localeInTemplate = (keyword.components(separatedBy: "@").count - 1 - argLowerBound) == 1
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
  
  func prepare(input: [String]) -> [Displayable] {
    guard let url = fillInTemplate(input: input) else { return [] }
    return [DisplayableContainer(name: name, content: fill(content: content, input: input), icon: icon, innerItem: url)]
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    let workspace = NSWorkspace.shared
    workspace.open(request)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    keyword = try container.decode(String.self, forKey: .keyword)
    template = try container.decode(String.self, forKey: .template)
    let lowerBound = try container.decode(Int.self, forKey: .argLowerBound)
    argLowerBound = lowerBound
    content = (try? container.decode(String.self, forKey: .content)) ?? ""
    argUpperBound = (try? container.decode(Int.self, forKey: .argUpperBound)) ?? lowerBound
    iconURL = try container.decode(String.self, forKey: .iconURL)
    loadImage()
  }
  
  private func loadImage() {
    let setupImage: (NSImage?)-> Void = { [weak self] in
      $0?.size = NSSize(width: 64, height: 64)
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
  
  static func load() -> [GeneralWebService] {
    let appSupDir = UserDefaults.standard.url(forKey: StoredKeys.appSupportDir.rawValue)!
    let serviceJSON = appSupDir.appendingPathComponent("Services/web.json")
    do {
      let jsonData = try Data(contentsOf: serviceJSON, options: .mappedIfSafe)
      let jsonDecoder = JSONDecoder()
      let services = try jsonDecoder.decode([GeneralWebService].self, from: jsonData)
      return services
    } catch {
      #if DEBUG
      debugPrint(error)
      #endif
    }
    return []
  }
}
