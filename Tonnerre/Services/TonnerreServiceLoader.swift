//
//  TonnerreServiceLoader.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-30.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TonnerreServiceLoader {
  /**
   A trie that contains all normal services (initialized after selection)
  */
  private let normalServiceTrie: Trie<TonnerreService.Type>
  /**
   A trie that contains all system services (initialized after selection)
   */
  private let systemServiceTrie: Trie<TonnerreService.Type>
  /**
   Prioritized services are loaded anyway, and they react user queries as input for `prepare(input:)`
  */
  private let prioritizedServices: [TonnerreService]
  /**
   Extended services are loaded from tne files or json files
   */
  let extensionServices: [TonnerreService]
  
  /**
   Indicates the service is normal or system
  */
  enum serviceType {
    /**
     Services that behave normal
    */
    case normal
    /**
     Services that may modify system preferences, and has no autoCompletion
    */
    case system
  }
  
  /**
   load services based on the input key and specified type
   - parameter keyword: the keyword user typed in the TonnerreField (first word). All services is located based on their keywords
   - parameter type: the type of service to load
  */
  func load(keyword: String, type: serviceType = .normal) -> [TonnerreService] {
    if type == .normal {
      let fetchedServices = normalServiceTrie.find(value: keyword)
        .filter { !$0.isDisabled }
        .map { $0.init() }
      return fetchedServices + extensionServices + prioritizedServices
    } else if type == .system {
      return systemServiceTrie.find(value: keyword).filter { !$0.isDisabled } .map { $0.init() }
    } else { return [] }
  }
  
  init() {
    prioritizedServices = [LaunchService(), CalculationService(), URLService(), CurrencyService()]
    extensionServices = [TNEServices(), WebExtService()]
    let normalServices: [TonnerreService.Type] = [FileNameSearchService.self, FileContentSearchService.self, GoogleSearch.self, AmazonSearch.self, WikipediaSearch.self, GoogleImageSearch.self, YoutubeSearch.self, GoogleMapService.self, TrashEmptyService.self, DictionarySerivce.self, GoogleTranslateService.self, BingSearch.self, DuckDuckGoSearch.self, LockService.self, ScreenSaverService.self, SafariBMService.self, ChromeBMService.self, TerminalService.self, ClipboardService.self]
    let systemServices: [TonnerreService.Type] = [ApplicationService.self, VolumeService.self]
    
    normalServiceTrie = Trie(values: normalServices + [SettingService.self]) { $0.keyword }
    systemServiceTrie = Trie(values: systemServices) { $0.keyword }
    if ClipboardService.isDisabled == false {
      ClipboardService.monitor.start()
    }
    setSettings(services: normalServices + systemServices + [CalculationService.self, CurrencyService.self], side: "left")
  }
  
  private func setSettings(services: [TonnerreService.Type], side: String) {
    let userDefault = UserDefaults.shared
    var settingsDict: SettingDict
    if let existingDict = userDefault.dictionary(forKey: .defaultSettingsSet), !existingDict.isEmpty {
      settingsDict = existingDict as! SettingDict
    } else if
      let settingURL = Bundle.main.url(forResource: "Settings", withExtension: "plist"),
      let plistContent = NSDictionary(contentsOf: settingURL) as? SettingDict {
      settingsDict = plistContent
    } else { fatalError("Settings cannot be loaded") }
    for service in services {
      let object = service.init()
      settingsDict["secondTab"]![side]![service.settingKey] =
        ["title":  object.name, "detail": object.content, "type": "gradient"]
    }
    userDefault.set(settingsDict, forKey: .defaultSettingsSet)
  }
}
