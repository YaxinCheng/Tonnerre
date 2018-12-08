//
//  BuiltinProviderInfo.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct BuiltinProviderInfo {
  let info: [(String, String, String, String)] = [
      ("Tonnerre.Provider.BuiltIn.GoogleSearch"             , "google", "Google", "Search on Google")
    , ("Tonnerre.Provider.BuiltIn.GoogleImageSearch"        , "image", "Google Image", "Search on Google Image")
    , ("Tonnerre.Provider.BuiltIn.YoutubeSearch"            , "youtube", "YouTube", "Find on YouTube")
    , ("Tonnerre.Provider.BuiltIn.AmazonSearch"             , "amazon", "Amazon", "Shop on Amazon")
    , ("Tonnerre.Provider.BuiltIn.WikipediaSearch"          , "wiki", "Wikipedia", "Search on Wikipedia")
    , ("Tonnerre.Provider.BuiltIn.BingSearch"               , "bing", "Bing", "Search on Bing")
    , ("Tonnerre.Provider.BuiltIn.DuckDuckGoSearch"         , "duck", "DuckDuckGo", "Search on DuckDuckGo")
    , ("Tonnerre.Provider.BuiltIn.DictionarySerivce"        , "define", "Define words...", "Find definition for word in dictionary")
    , ("Tonnerre.Provider.BuiltIn.GoogleTranslateService"   , "translate", "Google Translate", "Translate your language")
    , ("Tonnerre.Provider.BuiltIn.FileNameSearchService"    , "file", "Search files by names", "Search file on your mac and open")
    , ("Tonnerre.Provider.BuiltIn.FileContentSearchService" , "content", "Search files by content", "Search file on your mac and open")
    , ("Tonnerre.Provider.BuiltIn.GoogleMapService"         , "map", "Google Maps", "Search on Google Maps")
    , ("Tonnerre.Provider.BuiltIn.SafariBMService"          , "safari", "Safari BookMarks", "Quick launch Safari Bookmarks")
    , ("Tonnerre.Provider.BuiltIn.ChromeBMService"          , "chrome", "Chrome BookMarks", "Quick launch Chrome Bookmarks")
    , ("Tonnerre.Provider.BuiltIn.VolumeService"            , "eject", "Eject Volumes", "Eject selected volumes")
    , ("Tonnerre.Provider.BuiltIn.ClipboardService"         , "cb", "Clipboard Records", "Your records of recent copies")
    , ("Tonnerre.Provider.BuiltIn.ApplicationService"       , "quit", "Quit Programs", "Find and quite running programs")
  ]
}
