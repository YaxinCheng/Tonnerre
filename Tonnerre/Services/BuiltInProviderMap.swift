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
      "DictionarySerivce"        : "define"
    , "GoogleTranslateService"   : "translate"
    , "FileNameSearchService"    : "file"
    , "FileContentSearchService" : "content"
    , "GoogleMapService"         : "map"
    , "SafariBMService"          : "safari"
    , "ChromeBMService"          : "chrome"
    , "VolumeService"            : "eject"
    , "TerminalService"          : ">"
    , "ClipboardService"         : "cb"
    , "SettingService"           : "tonnerre"
  ]
  
  static func extractKeyword(from provider: BuiltInProvider.Type) -> String {
    let id = "\(provider.self)"
    return IDtoKeyword[id, default: ""]
  }
}
