//
//  SupportFoldersResource.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct SupportFoldersResource: EnvResource {
  func export(to env: Environment) {
    let folders: [SupportFolders] = [.base, .indices, .services, .cache]
    for folder in folders {
      do {
        guard !folder.exists else { continue }
        try folder.create()
      } catch {
        Logger.error(file: "\(self.self)", "Support Folders Creating Error: %{PUBLIC}@", error.localizedDescription)
      }
    }
  }
}
