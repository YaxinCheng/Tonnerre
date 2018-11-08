//
//  MapService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct GoogleMapService: WebService {
  let template: String = "https://maps.google.%@/?q=%@"
  let suggestionTemplate: String = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&key=AIzaSyBErLf0zbtiML5B_b1HdqAmLE2Um5xB6Aw"
  let alterContent: String? = "Open in Apple Maps"
  let argUpperBound: Int = .max
  
  func parse(suggestionData: Data?) -> [String] {
    guard
      let jsonData = suggestionData,
      let jsonObject = JSON(data: jsonData),
      (jsonObject["status"]?.rawValue as? String) == "OK",
      let predictions = jsonObject["predictions"]
    else { return [] }
    return predictions.compactMap { $0.value["description"]?.rawValue as? String }
  }
  let keyword: String = "map"
  let argLowerBound: Int = 1
  let name: String = "Google Maps"
  let contentTemplate: String = "Search %@ on Google Maps"
  let icon: NSImage = #imageLiteral(resourceName: "googlemap")
  var alterIcon: NSImage? {
    let workspace = NSWorkspace.shared
    let icon = workspace.icon(forFile: "/Applications/Maps.app")
    icon.size = NSSize(width: 64, height: 64)
    return icon
  }
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    guard let request = (service as? DisplayableContainer<URL>)?.innerItem else { return }
    let workspace = NSWorkspace.shared
    if withCmd {
      let appleMapURL = request.absoluteString.replacingOccurrences(of: "maps\\.google\\.\\w+?\\/", with: "maps.apple.com/", options: .regularExpression)
      workspace.open(URL(string: appleMapURL)!)
    } else {
      workspace.open(request)
    }
  }
}
