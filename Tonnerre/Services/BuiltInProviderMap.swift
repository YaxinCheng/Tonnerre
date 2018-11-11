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
  static private let IDtoKeyword: [String: String] = [
      "Tonnerre.Provider.BuiltIn.DictionarySerivce"        : "define"
    , "Tonnerre.Provider.BuiltIn.GoogleTranslateService"   : "translate"
    , "Tonnerre.Provider.BuiltIn.FileNameSearchService"    : "file"
    , "Tonnerre.Provider.BuiltIn.FileContentSearchService" : "content"
    , "Tonnerre.Provider.BuiltIn.GoogleMapService"         : "map"
    , "Tonnerre.Provider.BuiltIn.SafariBMService"          : "safari"
    , "Tonnerre.Provider.BuiltIn.ChromeBMService"          : "chrome"
    , "Tonnerre.Provider.BuiltIn.VolumeService"            : "eject"
    , "Tonnerre.Provider.BuiltIn.ClipboardService"         : "cb"
    , "Tonnerre.Provider.BuiltIn.SettingService"           : "tonnerre"
  ]
  
  static private let IDtoStruct: [String: BuiltInProvider.Type] = [
      "Tonnerre.Provider.BuiltIn.DictionarySerivce"        : DictionarySerivce.self
    , "Tonnerre.Provider.BuiltIn.GoogleTranslateService"   : GoogleTranslateService.self
    , "Tonnerre.Provider.BuiltIn.FileNameSearchService"    : FileNameSearchService.self
    , "Tonnerre.Provider.BuiltIn.FileContentSearchService" : FileContentSearchService.self
    , "Tonnerre.Provider.BuiltIn.GoogleMapService"         : GoogleMapService.self
    , "Tonnerre.Provider.BuiltIn.SafariBMService"          : SafariBMService.self
    , "Tonnerre.Provider.BuiltIn.ChromeBMService"          : ChromeBMService.self
    , "Tonnerre.Provider.BuiltIn.VolumeService"            : VolumeService.self
    , "Tonnerre.Provider.BuiltIn.ClipboardService"         : ClipboardService.self
    , "Tonnerre.Provider.BuiltIn.SettingService"           : SettingService.self
  ]
  
  static func extractKeyword(from provider: BuiltInProvider.Type) -> String {
    let id = "Tonnerre.Provider.BuiltIn.\(provider.self)"
    return IDtoKeyword[id, default: ""]
  }
  
  static func retrieveType(baseOnID id: String) -> BuiltInProvider.Type? {
    return IDtoStruct[id]
  }
}
