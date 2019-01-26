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
  
  func serve(service: DisplayItem, withCmd: Bool) {
    let workspace = NSWorkspace.shared
    let queue = DispatchQueue.global(qos: .userInitiated)
    if let allVolumes = (service as? DisplayContainer<[URL]>)?.innerItem {
      queue.async {
        var errorCount = 0
        for volume in allVolumes {
          do {
            try workspace.unmountAndEjectDevice(at: volume)
          } catch {
            errorCount += 1
            LocalNotification(title: "Eject Failed: \(volume.lastPathComponent)",
                              content: "Error: \(error)",
                              muted: false).send()
          }
        }
        if errorCount == 0 {
          LocalNotification(title: "Eject Successfully",
                            content: "Successfully ejected all volumes",
                            muted: true).send()
        }
      }
    } else if let specificVolume = (service as? DisplayContainer<URL>)?.innerItem {
      queue.async {
        do {
          try workspace.unmountAndEjectDevice(at: specificVolume)
          LocalNotification(title: "Eject Successfully",
                            content: "Ejected: \(specificVolume.lastPathComponent)",
                            muted: true).send()
        } catch {
          LocalNotification(title: "Eject Failed",
                            content: "Error: \(error)",
                            muted: false).send()
        }
      }
    }
  }
  
  func prepare(withInput input: [String]) -> [DisplayItem] {
    let fileManager = FileManager.default
    let semaphore = DispatchSemaphore(value: 0)
    var volumeURLs: [URL] = []
    DispatchQueue(label: "volumeChecking").async {
      // this action may take very long time when ejection is called but not completed
      // put it in a different queue to prevent from freezing the main queue
      volumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsInternalKey],
                                                 options: .skipHiddenVolumes) ?? []
      semaphore.signal()
    }
    _ = semaphore.wait(timeout: .now() + 0.2)// timeout set to 0.2 seconds
    let noEjectable = DisplayContainer<Error>(name: "Eject Service",
                                             content: "No ejectable volumes",
                                             icon: icon, placeholder: keyword)
    guard !volumeURLs.isEmpty else { return [noEjectable] }
    let workspace = NSWorkspace.shared
    let externalVolumes = volumeURLs.filter { !(try! $0.resourceValues(forKeys: [.volumeIsInternalKey]).volumeIsInternal ?? false) }
    guard !externalVolumes.isEmpty else { return [noEjectable] }
    let volumeRequest = externalVolumes.map {
      DisplayContainer<URL>(name: $0.lastPathComponent, content: $0.path,
                            icon: workspace.icon(forFile: $0.path), innerItem: $0)
    }
    let ejectAllRequest = DisplayContainer<[URL]>(name: "Eject All",
                                                  content: "Safely eject all external volumes",
                                                  icon: icon, innerItem: externalVolumes)
    return [ejectAllRequest] + volumeRequest
  }
}
