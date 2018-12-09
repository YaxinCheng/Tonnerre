//
//  TNEProviderLoader.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-08.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct TNEProviderLoader {
  private let path = UserDefaults.shared.url(forKey: "appSupportDir")!.appendingPathComponent("Services")
  
  var providers: [(String, String, String, String)] {
    do {
      let content = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
      return content.filter { $0.pathExtension == "tne" }.compactMap(extractInfo)
    } catch {
      #if DEBUG
      print("TNEProviderLoader", error)
      #endif
      return []
    }
  }
  
  private func extractInfo(fromTNEPath path: URL) -> (String, String, String, String)? {
    do {
      let descriptionJSONPath = path.appendingPathComponent("description.json")
      let data = try Data(contentsOf: descriptionJSONPath)
      guard
        let descriptionJSON = JSON(data: data),
        let keyword: String = descriptionJSON["keyword"],
        let name: String = descriptionJSON["name"],
        let content: String = descriptionJSON["content"]
      else { return nil }
      let id = "Tonnerre.Provider.Extension.\(path.deletingPathExtension().lastPathComponent)"
      return (id, keyword, name, content.filled(arguments: ["..."]))
    } catch {
      return nil
    }
  }
}
