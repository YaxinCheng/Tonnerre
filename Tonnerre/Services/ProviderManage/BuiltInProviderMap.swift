//
//  BuiltInProviderMap.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct BuiltInProviderMap {
  /// provider_id to keyword
  static let IDtoKeyword: [String: String] = [
      "Tonnerre.Provider.BuiltIn.URLService"               : ""
    , "Tonnerre.Provider.BuiltIn.CalculationService"       : ""
    , "Tonnerre.Provider.BuiltIn.LaunchService"            : ""
    , "Tonnerre.Provider.BuiltIn.GoogleSearch"             : "google"
    , "Tonnerre.Provider.BuiltIn.GoogleImageSearch"        : "image"
    , "Tonnerre.Provider.BuiltIn.YoutubeSearch"            : "youtube"
    , "Tonnerre.Provider.BuiltIn.AmazonSearch"             : "amazon"
    , "Tonnerre.Provider.BuiltIn.WikipediaSearch"          : "wiki"
    , "Tonnerre.Provider.BuiltIn.BingSearch"               : "bing"
    , "Tonnerre.Provider.BuiltIn.DuckDuckGoSearch"         : "duck"
    , "Tonnerre.Provider.BuiltIn.DictionarySerivce"        : "define"
    , "Tonnerre.Provider.BuiltIn.GoogleTranslateService"   : "translate"
    , "Tonnerre.Provider.BuiltIn.FileNameSearchService"    : "file"
    , "Tonnerre.Provider.BuiltIn.FileContentSearchService" : "content"
    , "Tonnerre.Provider.BuiltIn.GoogleMapService"         : "map"
    , "Tonnerre.Provider.BuiltIn.SafariBMService"          : "safari"
    , "Tonnerre.Provider.BuiltIn.ChromeBMService"          : "chrome"
    , "Tonnerre.Provider.BuiltIn.VolumeService"            : "eject"
    , "Tonnerre.Provider.BuiltIn.ClipboardService"         : "cb"
    , "Tonnerre.Provider.BuiltIn.SettingService"           : "tonnerre"
    , "Tonnerre.Provider.BuiltIn.ApplicationService"       : "quit"
  ]
  
  static let IDtoStruct: [String: BuiltInProvider.Type] = [
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
  ]
  
  static func extractKeyword(from provider: BuiltInProvider.Type) -> String {
    let id = "Tonnerre.Provider.BuiltIn.\(provider.self)"
    return IDtoKeyword[id, default: ""]
  }
  
  static func retrieveType(baseOnID id: String) -> BuiltInProvider.Type? {
    return IDtoStruct[id]
  }
}
