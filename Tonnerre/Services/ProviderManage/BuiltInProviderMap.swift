//
//  BuiltInProviderMap.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct BuiltInProviderMap {
  static let IdToType: [String: BuiltInProvider.Type] = [
      "Tonnerre.Provider.BuiltIn.URLService"               : URLService.self
    , "Tonnerre.Provider.BuiltIn.CalculationService"       : CalculationService.self
    , "Tonnerre.Provider.BuiltIn.LaunchService"            : LaunchService.self
    , "Tonnerre.Provider.BuiltIn.GoogleSearch"             : GoogleSearch.self
    , "Tonnerre.Provider.BuiltIn.GoogleImageSearch"        : GoogleImageSearch.self
    , "Tonnerre.Provider.BuiltIn.YoutubeSearch"            : YoutubeSearch.self
    , "Tonnerre.Provider.BuiltIn.AmazonSearch"             : AmazonSearch.self
    , "Tonnerre.Provider.BuiltIn.WikipediaSearch"          : WikipediaSearch.self
    , "Tonnerre.Provider.BuiltIn.BingSearch"               : BingSearch.self
    , "Tonnerre.Provider.BuiltIn.DuckDuckGoSearch"         : DuckDuckGoSearch.self
    , "Tonnerre.Provider.BuiltIn.DictionarySerivce"        : DictionarySerivce.self
    , "Tonnerre.Provider.BuiltIn.GoogleTranslateService"   : GoogleTranslateService.self
    , "Tonnerre.Provider.BuiltIn.FileNameSearchService"    : FileNameSearchService.self
    , "Tonnerre.Provider.BuiltIn.FileContentSearchService" : FileContentSearchService.self
    , "Tonnerre.Provider.BuiltIn.GoogleMapService"         : GoogleMapService.self
    , "Tonnerre.Provider.BuiltIn.SafariBMService"          : SafariBMService.self
    , "Tonnerre.Provider.BuiltIn.ChromeBMService"          : ChromeBMService.self
    , "Tonnerre.Provider.BuiltIn.VolumeService"            : VolumeService.self
    , "Tonnerre.Provider.BuiltIn.ClipboardService"         : ClipboardService.self
    , "Tonnerre.Provider.BuiltIn.SettingService"           : SettingService.self
    , "Tonnerre.Provider.BuiltIn.ApplicationService"       : ApplicationService.self
    , "Tonnerre.Provider.BuiltIn.GoogleTranslateAutoService": GoogleTranslateAutoService.self
  ]
  
  private static let _ID_TEMPLATE = "Tonnerre.Provider.BuiltIn.%@"
  
  static func extractID(from provider: BuiltInProvider.Type) -> String {
    return String(format: _ID_TEMPLATE, "\(provider)")
  }
  
  static func extractKeyword(from provider: BuiltInProvider.Type) -> String {
    let key = extractID(from: provider) + ".keyword"
    return UserDefaults.shared.string(forKey: key) ?? provider.init().defaultKeyword
  }
  
  static func retrieveType(baseOnID id: String) -> BuiltInProvider.Type? {
    return IdToType[id]
  }
  
  static var associatedKeywordsWithIds: [(String, String)] {
    return IdToType.map { (extractKeyword(from: $0.value), $0.key) }
  }
}
