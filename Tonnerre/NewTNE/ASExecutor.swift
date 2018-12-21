//
//  ASExecutor.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct ASExecutor: TNEExecutor {
  let scriptPath: URL
  
  init?(scriptPath: URL) {
    let mainScript = scriptPath.appendingPathComponent("main.scpt")
    guard
      FileManager.default.fileExists(atPath: mainScript.path)
    else { return nil }
    self.scriptPath = mainScript
  }
  
  func execute(withArguments args: Arguments) throws -> JSON? {
    switch args {
    case .supply(input: _): break
    case .serve(choice: _):
      let task = try NSUserAppleScriptTask(url: scriptPath)
      task.execute()
    }
    return nil
  }

}
