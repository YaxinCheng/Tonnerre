//
//  GeneralWebServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-04.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class GeneralWebService: WebService, Codable {
  let keyword: String
  let template: String
  let argLowerBound: Int
  let iconURL: String
  let name: String
  let contentTemplate: String
  let suggestionTemplate: String = ""
  let loadSuggestion: Bool = false
  let hasPreview: Bool = false
  let argUpperBound: Int
  var icon: NSImage {
    return storedImage ?? #imageLiteral(resourceName: "safari")
  }
  private var storedImage: NSImage?
  
  // Deprecate
  required init() {// This should not be called
    fatalError("This should never be called")
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    keyword = try container.decode(String.self, forKey: .keyword)
    template = try container.decode(String.self, forKey: .template)
    let lowerBound = try container.decode(Int.self, forKey: .argLowerBound)
    argLowerBound = lowerBound
    iconURL = try container.decode(String.self, forKey: .iconURL)
    contentTemplate = (try? container.decode(String.self, forKey: .contentTemplate)) ?? ""
    argUpperBound = (try? container.decode(Int.self, forKey: .argUpperBound)) ?? lowerBound
  }
  
  enum CodingKeys: String, CodingKey {
    case name
    case contentTemplate = "content"//optional
    case keyword
    case template
    case argLowerBound
    case iconURL = "icon"
    case argUpperBound
  }
  
  func processJSON(data: Data?) -> [String : Any] {
    return [:]
  }
  
  fileprivate func loadImage() {
    let setupImage: (NSImage?)-> Void = {
      $0?.size = NSSize(width: 64, height: 64)
      self.storedImage = $0
    }
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
      for service in services { service.loadImage() }
      return services
    } catch {
      #if DEBUG
      debugPrint(error)
      #endif 
    }
    return []
  }
}
