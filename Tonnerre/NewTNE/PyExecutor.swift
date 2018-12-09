//
//  PyExecutor.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-11-10.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct PyExecutor: TNEExecutor {
  let scriptPath: URL
  private class Cache {
    var currentProcess: Process?
  }
  
  private let cache = Cache()
  
  init?(scriptPath: URL) {
    let mainScript = scriptPath.appendingPathComponent("main.py")
    guard FileManager.default.fileExists(atPath: mainScript.path) else { return nil }
    self.scriptPath = mainScript
  }
  
  func execute(withArguments args: Arguments) throws -> JSON? {
    let process = buildProcess(withArguments: args)
    if cache.currentProcess?.isRunning == true { cache.currentProcess?.terminate() }
    cache.currentProcess = process
    try process.run()
    
    let runtimeErrorData = (process.standardError as! Pipe).fileHandleForReading.readDataToEndOfFile()
    if !runtimeErrorData.isEmpty,
      let errorMsg = JSON(data: runtimeErrorData)?["error"] as? String {
      throw TNEExecutor.Error.runtimeError(reason: errorMsg)
    }
    
    guard case .supply(_) = args else { return nil }
    let outputData = (process.standardOutput as! Pipe).fileHandleForReading.readDataToEndOfFile()
    return JSON(data: outputData)
  }
  
  private func buildProcess(withArguments args: Arguments) -> Process {
    let process = Process()
    process.standardInput  = Pipe()
    process.standardOutput = Pipe()
    process.standardError  = Pipe()
    
    let dynamicServiceURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Scripts/DynamicServiceExec.py")
    let arguments = [dynamicServiceURL.path, args.argumentType, scriptPath.path]
    let pythonPath = (TonnerreSettings.get(fromKey: .python) as? String) ?? "/usr/bin/python"
    process.executableURL = URL(fileURLWithPath: pythonPath)
    process.arguments = arguments
    
    let argumentJSON: JSON
    switch args {
    case .supply(input: let input): argumentJSON = JSON(array: input)
    case .serve(choice: let choice): argumentJSON = JSON(dictionary: choice)
    }
    let stdin = process.standardInput as! Pipe
    stdin.fileHandleForWriting.write(try! argumentJSON.serialized())
    stdin.fileHandleForWriting.closeFile()
    return process
  }
}
