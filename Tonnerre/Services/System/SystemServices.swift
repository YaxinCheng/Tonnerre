//
//  SystemServices.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-05.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol SystemService: TonnerreService {
  
}
extension SystemService {
  var hasPreview: Bool { return false }
}

struct ApplicationService: SystemService {
  let name: String = "Quit program"
  let content: String = "Find and quite a running program"
  let alterContent: String? = "Force quit program"
  let keyword: String = "quit"
  let icon: NSImage = #imageLiteral(resourceName: "close")
  let arguments: [String] = []
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let value = (source as? SystemRequest<NSRunningApplication>)?.innerItem else { return }
    if withCmd { value.forceTerminate() }
    else { value.terminate() }
  }

  func prepare(input: [String]) -> [Displayable] {
    let workspace = NSWorkspace.shared
    let runningApps = workspace.runningApplications.filter { $0.activationPolicy == .regular }
    if input.isEmpty {
      return runningApps.map { SystemRequest(name: $0.localizedName!, content: $0.bundleURL!.path, icon: $0.icon!, innerItem: $0) }
    } else {
      let filteredApps = runningApps.filter { $0.localizedName!.lowercased().starts(with: input.joined(separator: " "))}
      return filteredApps.map { SystemRequest(name: $0.localizedName!, content: $0.bundleURL!.path, icon: $0.icon!, innerItem: $0) }
    }
  }
}

struct VolumeService: SystemService {
  let name: String = "Eject Volumes"
  let content: String = "Eject selected volumes"
  let keyword: String = "eject"
  let icon: NSImage = #imageLiteral(resourceName: "eject")
  let arguments: [String] = []
  
  private func send(notification: NSUserNotification) {
    let centre = NSUserNotificationCenter.default
    centre.deliver(notification)
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    let fileManager = FileManager.default
    if let allVolumes = (source as? SystemRequest<[URL]>)?.innerItem {
      for volume in allVolumes {
        fileManager.unmountVolume(at: volume, options: .withoutUI) { (error) in
          let localNotification = NSUserNotification()
          if error != nil {
            localNotification.title = "Eject Failed"
            localNotification.informativeText = "Error: \(error!)"
            localNotification.soundName = NSUserNotificationDefaultSoundName
            self.send(notification: localNotification)
          } else {
            localNotification.title = "Eject Successfully"
            localNotification.informativeText = "Ejected: \(volume.lastPathComponent)"
            localNotification.soundName = nil
            self.send(notification: localNotification)
          }
        }
      }
    } else if let specificVolume = (source as? SystemRequest<URL>)?.innerItem {
      fileManager.unmountVolume(at: specificVolume, options: .withoutUI) { (error) in
        let localNotification = NSUserNotification()
        localNotification.title = "Eject Successfully"
        localNotification.informativeText = "Ejected: \(specificVolume.lastPathComponent)"
        localNotification.soundName = nil
        self.send(notification: localNotification)
      }
    }
  }
  
  func prepare(input: [String]) -> [Displayable] {
    let fileManager = FileManager.default
    let volumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsInternalKey], options: .skipHiddenVolumes) ?? []
    guard !volumeURLs.isEmpty else { return [] }
    let workspace = NSWorkspace.shared
    let externalVolumes = volumeURLs.filter { !(try! $0.resourceValues(forKeys: [.volumeIsInternalKey]).volumeIsInternal ?? true) }
    guard !externalVolumes.isEmpty else { return [] }
    let volumeRequest = externalVolumes.map {
      SystemRequest<URL>(name: $0.lastPathComponent, content: $0.path, icon: workspace.icon(forFile: $0.path), innerItem: $0)
    }
    let ejectAllRequest = SystemRequest<[URL]>(name: "Eject All", content: "Safely eject all external volumes", icon: #imageLiteral(resourceName: "eject"), innerItem: externalVolumes)
    return [ejectAllRequest] + volumeRequest
  }
}
