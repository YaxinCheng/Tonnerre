//
//  VolumeService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-08-07.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

struct VolumeService: TonnerreService {
  let name: String = "Eject Volumes"
  let content: String = "Eject selected volumes"
  static let keyword: String = "eject"
  var icon: NSImage {
    return #imageLiteral(resourceName: "eject").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  let argUpperBound: Int = Int.max
  let argLowerBound: Int = 0
  
  func serve(source: DisplayProtocol, withCmd: Bool) {
    let workspace = NSWorkspace.shared
    let queue = DispatchQueue.global(qos: .userInitiated)
    if let allVolumes = (source as? DisplayableContainer<[URL]>)?.innerItem {
      queue.async {
        var errorCount = 0
        for volume in allVolumes {
          do {
            try workspace.unmountAndEjectDevice(at: volume)
          } catch {
            errorCount += 1
            LocalNotification.send(title: "Eject Failed", content: "Error: \(error)", muted: false)
          }
        }
        if errorCount == 0 {
          LocalNotification.send(title: "Eject Successfully", content: "Successfully ejected all volumes")
        }
      }
    } else if let specificVolume = (source as? DisplayableContainer<URL>)?.innerItem {
      queue.async {
        do {
          try workspace.unmountAndEjectDevice(at: specificVolume)
          LocalNotification.send(title: "Eject Successfully", content: "Ejected: \(specificVolume.lastPathComponent)")
        } catch {
          LocalNotification.send(title: "Eject Failed", content: "Error: \(error)", muted: false)
        }
      }
    }
  }
  
  func prepare(input: [String]) -> [DisplayProtocol] {
    let fileManager = FileManager.default
    let semaphore = DispatchSemaphore(value: 0)
    var volumeURLs: [URL] = []
    DispatchQueue(label: "volumeChecking").async {
      volumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsInternalKey], options: .skipHiddenVolumes) ?? []
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + 0.2)
    let noEjectable = DisplayableContainer<Int?>(name: "Eject Service", content: "No ejectable volumes", icon: icon, priority: priority)
    guard !volumeURLs.isEmpty else { return [noEjectable] }
    let workspace = NSWorkspace.shared
    let externalVolumes = volumeURLs.filter { !(try! $0.resourceValues(forKeys: [.volumeIsInternalKey]).volumeIsInternal ?? false) }
    guard !externalVolumes.isEmpty else { return [noEjectable] }
    let volumeRequest = externalVolumes.map {
      DisplayableContainer<URL>(name: $0.lastPathComponent, content: $0.path, icon: workspace.icon(forFile: $0.path), priority: priority, innerItem: $0)
    }
    let ejectAllRequest = DisplayableContainer<[URL]>(name: "Eject All", content: "Safely eject all external volumes", icon: icon, priority: priority, innerItem: externalVolumes)
    return [ejectAllRequest] + volumeRequest
  }
}
