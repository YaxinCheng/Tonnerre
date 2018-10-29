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
      let jsonObject = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: Any],
      (jsonObject["status"] as? String) == "OK",
      let predictions = jsonObject["predictions"] as? [[String: Any]]
    else { return [] }
    return predictions.compactMap { $0["description"] as? String }
  }
  static let keyword: String = "map"
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
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    guard let request = (source as? DisplayableContainer<URL>)?.innerItem else { return }
    let workspace = NSWorkspace.shared
    if withCmd {
      let appleMapURL = request.absoluteString.replacingOccurrences(of: "maps\\.google\\.\\w+?\\/", with: "maps.apple.com/", options: .regularExpression)
      workspace.open(URL(string: appleMapURL)!)
    } else {
      workspace.open(request)
    }
  }
}
