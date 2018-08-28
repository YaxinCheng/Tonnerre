//
//  PythonService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

final class PythonService: DynamicScriptService {
  var serviceTrie: Trie<DynamicProtocol.ServiceType>
  static var runningProcesses: [Process] = []
  var cachedKey: String?
  var cachedServices: [DynamicProtocol.ServiceType] = []
  static let scriptExtension: String = ".py"
  
  init() {
    serviceTrie = Trie(values: []) { $0.extraContent as! String }
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      self.prefetch(fileExtension: "tne")
    }
  }
  
  func execute(script: ServiceType, runningMode: DynamicScriptMode) throws -> [DisplayProtocol] {
    guard let scriptPath = script.innerItem, FileManager.default.fileExists(atPath: scriptPath) else { return [] }
    let (inputPipe, outputPipe, errorPipe) = (Pipe(), Pipe(), Pipe())
    let process = Process()
    process.arguments = [Bundle.main.url(forResource: "DynamicServiceExec", withExtension: "py")!.path, runningMode.argument, scriptPath]
    let userDefault = UserDefaults.shared
    let pythonPath = (userDefault[.python] as? String) ?? "/usr/bin/python"
    process.executableURL = URL(fileURLWithPath: pythonPath)
    process.standardInput = inputPipe
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    switch runningMode {
    case .prepare(input: let input):
      inputPipe.fileHandleForWriting.write(try JSONSerialization.data(withJSONObject: input, options: .prettyPrinted))
    case .serve(choice: let choice):
      inputPipe.fileHandleForWriting.write(try JSONSerialization.data(withJSONObject: choice, options: .prettyPrinted))
    }
    inputPipe.fileHandleForWriting.closeFile()
    type(of: self).runningProcesses.append(process)
    try process.run()
    let runningError = errorPipe.fileHandleForReading.readDataToEndOfFile()
    if !runningError.isEmpty,
      let errorDict = try JSONSerialization.jsonObject(with: runningError, options: .mutableLeaves) as? Dictionary<String, Any>,
      let error = errorDict["error"],
      let errorItem = decode(["name": "Error", "content": error, "placeholder": ""], withIcon: script.icon)
    {
      return [errorItem]
    }
    let runningResult = outputPipe.fileHandleForReading.readDataToEndOfFile()
    if !runningResult.isEmpty,
      let result = try JSONSerialization.jsonObject(with: runningResult, options: .mutableLeaves) as? [Dictionary<String, Any>] {
      return result.compactMap { decode($0, withIcon: script.icon, extraInfo: script) }
    }
    return []
  }
}
