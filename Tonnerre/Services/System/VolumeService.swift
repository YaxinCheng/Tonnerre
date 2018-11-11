//
//  VolumeService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

struct VolumeService: BuiltInProvider {
  let name: String = "Eject Volumes"
  let content: String = "Eject selected volumes"
  let keyword: String = "eject"
  let icon: NSImage = #imageLiteral(resourceName: "eject")
  let argUpperBound: Int = .max
  let argLowerBound: Int = 0
  
  func serve(service: DisplayProtocol, withCmd: Bool) {
    let workspace = NSWorkspace.shared
    let queue = DispatchQueue.global(qos: .userInitiated)
    if let allVolumes = (service as? DisplayableContainer<[URL]>)?.innerItem {
      queue.async {
        var errorCount = 0
        for volume in allVolumes {
          do {
            try workspace.unmountAndEjectDevice(at: volume)
          } catch {
            errorCount += 1
            LocalNotification.send(title: "Eject Failed", content: "Error: \(error)")
          }
        }
        if errorCount == 0 {
          LocalNotification.send(title: "Eject Successfully", content: "Successfully ejected all volumes", muted: true)
        }
      }
    } else if let specificVolume = (service as? DisplayableContainer<URL>)?.innerItem {
      queue.async {
        do {
          try workspace.unmountAndEjectDevice(at: specificVolume)
          LocalNotification.send(title: "Eject Successfully", content: "Ejected: \(specificVolume.lastPathComponent)", muted: true)
        } catch {
          LocalNotification.send(title: "Eject Failed", content: "Error: \(error)")
        }
      }
    }
  }
  
  func prepare(withInput input: [String]) -> [DisplayProtocol] {
    let fileManager = FileManager.default
    let semaphore = DispatchSemaphore(value: 0)
    var volumeURLs: [URL] = []
    DispatchQueue(label: "volumeChecking").async {
      volumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsInternalKey], options: .skipHiddenVolumes) ?? []
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + 0.2)
    let noEjectable = DisplayableContainer<Int?>(name: "Eject Service", content: "No ejectable volumes", icon: icon)
    guard !volumeURLs.isEmpty else { return [noEjectable] }
    let workspace = NSWorkspace.shared
    let externalVolumes = volumeURLs.filter { !(try! $0.resourceValues(forKeys: [.volumeIsInternalKey]).volumeIsInternal ?? false) }
    guard !externalVolumes.isEmpty else { return [noEjectable] }
    let volumeRequest = externalVolumes.map {
      DisplayableContainer<URL>(name: $0.lastPathComponent, content: $0.path, icon: workspace.icon(forFile: $0.path), innerItem: $0)
    }
    let ejectAllRequest = DisplayableContainer<[URL]>(name: "Eject All", content: "Safely eject all external volumes", icon: icon, innerItem: externalVolumes)
    return [ejectAllRequest] + volumeRequest
  }
}
