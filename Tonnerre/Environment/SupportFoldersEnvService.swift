//
//  SupportFoldersEnvService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2019-02-27.
//  Copyright © 2019 Yaxin Cheng. All rights reserved.
//

import Foundation

struct SupportFoldersEnvService: EnvService {
  func setup() {
    let folders: [SupportFolders] = [.base, .indices, .services, .cache]
    for folder in folders {
      do {
        guard !folder.exists else { continue }
        try folder.create()
      } catch {
        #if DEBUG
        print("Create folder error", error)
        #endif
      }
    }
  }
}
