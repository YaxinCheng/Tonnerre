//
//  DynamicScriptService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-20.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

enum DynamicScriptMode {
  case prepare(input: [String])
  case serve(choice: [String: Any])
  
  var argument: String {
    switch self {
    case .prepare(input: _): return "--prepare"
    case .serve(choice: _): return "--serve"
    }
  }
}

protocol DynamicScriptService: TonnerreService, DynamicProtocol, AsyncLoadingProtocol {
  /**
   The trie where all services stored
   */
  var serviceTrie: Trie<ServiceType> { get set }
  /**
   The process which is on executing
   */
  static var runningProcesses: [Process] { get set }
  /**
   Cached request key. Used to avoid duplicate writting and requesting from the Trie
   */
  var cachedKey: String? { get set }
  /**
   Cached services.
   */
  var cachedServices: [ServiceType] { get set }
  /**
   The extension of a certain script
  */
  static var scriptExtension: String { get }
  /**
   Parse information in a json file to get the service
   - parameter url: the url to the TNE script
   - returns: (keyword, DisplayableContainer with information in the JSON)
   */
  static func generateService(from url: URL) -> [ServiceType]
  /**
   Run the given script for a specific mode
   - parameter script: a service that provided with the dynamic script file
   - parameter runningMode: either `prepare` or `serve`. It determines which function in the script should be called
   - throws: Error of process running; Error of JSONSerialization
   - returns: an array of running result, can be empty (if with serve mode)
   */
  func execute(script: ServiceType, runningMode: DynamicScriptMode) throws -> [DisplayProtocol]
}

extension DynamicScriptService {
  static var keyword: String { return "" }
  var icon: NSImage {
    return #imageLiteral(resourceName: "tonnerre_extension").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  var argLowerBound: Int { return 0 }
  var argUpperBound: Int { return .max }
  
  var asyncSession: TonnerreSession { return .shared }
  
  // MARK: - Tool
  func decode(_ jsonObject: Dictionary<String, Any>, withIcon: NSImage, extraInfo: Any? = nil) -> DisplayProtocol? {
    guard
      let rawName = jsonObject["name"]
    else { return nil }
    let name: String = rawName as? String ?? String(reflecting: rawName)
    let content = jsonObject["content"] as? String ?? ""
    let innerItem = jsonObject["innerItem"]
    let placeholder = jsonObject["placeholder"] as? String ?? name
    if
      let stringItem = innerItem as? String,
      let urlItem = URL(string: stringItem),
      let _ = NSWorkspace.shared.urlForApplication(toOpen: urlItem) {
      return DisplayableContainer(name: name, content: content, icon: withIcon, innerItem: urlItem, placeholder: placeholder, extraContent: extraInfo)
    } else {
      return DisplayableContainer<Any>(name: name, content: content, icon: withIcon, innerItem: innerItem, placeholder: placeholder, extraContent: extraInfo)
    }
  }
  
  func dictionarize(_ displayItem: DisplayProtocol) -> Dictionary<String, Any> {
    let unwrap: (Any) -> Any = {
      let mirror = Mirror(reflecting: $0)
      guard
        mirror.displayStyle == .optional,
        let value = mirror.children.first
      else { return $0 }
      return value.value
    }
    let requiredKeys: Set<String> = ["name", "content", "innerItem"]
    return Dictionary(uniqueKeysWithValues:
      Mirror(reflecting: displayItem).children
      .filter { requiredKeys.contains(($0.label ?? "")) }
      .map { ($0.label!, $0.value as? String ?? String(reflecting: unwrap($0.value))) }
    )
  }
  
  // MARK: - Constructions
  static func generateService(from url: URL) -> [ServiceType] {
    let script = url.appendingPathComponent("main" + scriptExtension)
    guard FileManager.default.fileExists(atPath: script.path) else { return [] }
    let iconURL = url.appendingPathComponent("icon.png")
    let fileIcon = NSImage(contentsOf: iconURL)
    let jsonURL = url.appendingPathComponent("description.json")
    do {
      let jsonData = try Data(contentsOf: jsonURL)
      let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? Dictionary<String, String>
      guard
        let descriptionObj = jsonObject,
        let name = descriptionObj["name"],
        let keyword = descriptionObj["keyword"]
      else { return [] }
      let icon: NSImage
      if fileIcon != nil { icon = fileIcon! }
      else if let iconPath = descriptionObj["icon"], let iconFromPath = NSImage(contentsOfFile: iconPath) {
        icon = iconFromPath
      } else { icon = #imageLiteral(resourceName: "tonnerre_extension").tintedImage(with: TonnerreTheme.current.imgColour) }
      let item = DisplayableContainer(name: name, content: descriptionObj["content"] ?? "", icon: icon, innerItem: script.path, placeholder: descriptionObj["placeholder"] ?? "", extraContent: keyword)
      return [item]
    } catch {
      #if DEBUG
      print("Error happened in generate service: ", error)
      #endif
      return []
    }
  }
  
  func reload() {
    serviceTrie = Trie(values: []) { $0.extraContent as! String }
    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
      self.prefetch(fileExtension: "tne")
    }
  }
  
  // MARK: - TonnerreService functions
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    guard input.count > 0 else { return [] }
    let queryKey = input.first!.lowercased()
    let possibleServices: [DisplayableContainer<String>]
    if let cache = cachedKey, cache == queryKey {
      possibleServices = cachedServices
    } else {
      cachedKey = queryKey
      let userDefault = UserDefaults.shared
      possibleServices = serviceTrie.find(value: queryKey).filter {
        !userDefault.bool(forKey: "\($0.extraContent ?? "")_\($0.name)_\($0.content)+isDisabled")
      }
      cachedServices = possibleServices
    }
    if input.count > 1 {
      let queryContent = Array(input[1...])
      let task = DispatchWorkItem { [unowned self] in
        Self.runningProcesses.forEach { $0.terminate() }
        Self.runningProcesses.removeAll(keepingCapacity: true)
        let content = possibleServices.compactMap { try? self.execute(script: $0, runningMode: .prepare(input: queryContent)) }.reduce([], +)
        guard content.count > 0 else { return }
        let notification = Notification(name: .asyncLoadingDidFinish, object: self, userInfo: ["rawElements": content])
        NotificationCenter.default.post(notification)
      }
      asyncSession.send(request: task)
      var filledService = [DisplayableContainer<String>]()
      for var service in possibleServices {
        service.content = fill(template: service.content, withArguments: queryContent)
        filledService.append(service)
      }
      return filledService
    }
    return possibleServices
  }
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
      let originalService: DisplayableContainer<String>
      if let urlResult = source as? DisplayableContainer<URL>,
        let service = urlResult.extraContent as? ServiceType {
        originalService = service
      } else if
        let anyResult = source as? DisplayableContainer<Any>,
        let service = anyResult.extraContent as? ServiceType {
        originalService = service
      } else { return }
      Self.runningProcesses.forEach { $0.terminate() }
      Self.runningProcesses.removeAll(keepingCapacity: true)
      var dictionarizedChoice = self.dictionarize(source)
      dictionarizedChoice["withCmd"] = withCmd
      do {
        _ = try self.execute(script: originalService, runningMode: .serve(choice: dictionarizedChoice))
      } catch {
        #if DEBUG
        print("Serve Error: ", error)
        #endif
      }
    }
  }
  
  var mode: AsyncLoadingType {
    return .replaced
  }
  
  func present(rawElements: [Any]) -> [ServicePack] {
    guard rawElements is [DisplayProtocol] else { return [] }
    return (rawElements as! [DisplayProtocol]).map { ServicePack(provider: self, service: $0) }
  }
}
