//
//  WebServiceList.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-03-29.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct WebServiceList {
  /// Shared instance for WebServiceList that links to the webServiceList.plist
  static let shared = WebServiceList()
  private let suggestionList: [String: String]
  private let servicesList: [String: [String: String]]
  
  private static let _RESOURCE_NAME = "webServices"
  private let _SUGGESTION_KEY = "suggestionTemplate"
  private let _TEMPLATE_KEY = "template"
  
  private static var resourceName: String {
    let localeSuffix = (Locale.current.regionCode ?? "").lowercased()
    let regionalResourceName = [_RESOURCE_NAME, localeSuffix].joined(separator: "_")
    return Bundle.main.url(forResource: regionalResourceName, withExtension: "plist") == nil ? _RESOURCE_NAME : regionalResourceName
  }
  
  private init() {
    let content: Result<[String:Any], Error> = PropertyListSerialization.read(fileName: WebServiceList.resourceName)
    switch content {
    case .success(let listObj):
      suggestionList = listObj[Attribute.suggestionsTemplate.rawValue] as? [String : String] ?? [:]
      servicesList = listObj[Attribute.serviceTemplate.rawValue] as? [String : [String : String]] ?? [:]
    case .failure(let error):
      Logger.error(file: WebServiceList.self, "Reading %{PUBLIC}@ Error: %{PUBLIC}@", WebServiceList.resourceName, error.localizedDescription)
      (suggestionList, servicesList) = ([:], [:])
    }
  }
  
  /// The attribute from the webServiceList, either suggestion or service
  enum Attribute: String {
    case suggestionsTemplate = "Suggestions"
    case serviceTemplate = "Services"
  }
  
  /// Retrieve attribute value from the list
  subscript(_ service: WebService, attribute: Attribute) -> String {
    let typeName = "\(type(of: service))"
    let serviceMod = servicesList[typeName]
    switch attribute {
    case .serviceTemplate: return serviceMod?[_TEMPLATE_KEY] ?? ""
    case .suggestionsTemplate:
      let suggestionMod = serviceMod?[_SUGGESTION_KEY] ?? ""
      return suggestionList[suggestionMod] ?? ""
    }
  }
}
