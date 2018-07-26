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

struct ApplicationService: SystemService {
  let name: String = "Quit program"
  let content: String = "Find and quite a running program"
  let alterContent: String? = "Force quit program"
  static let keyword: String = "quit"
  var icon: NSImage {
    return #imageLiteral(resourceName: "close").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  let argUpperBound: Int = Int.max
  let argLowerBound: Int = 0
  
  func serve(source: Displayable, withCmd: Bool) {
    guard let value = (source as? DisplayableContainer<NSRunningApplication>)?.innerItem else { return }
    if withCmd { value.forceTerminate() }
    else { value.terminate() }
  }

  func prepare(input: [String]) -> [Displayable] {
    let workspace = NSWorkspace.shared
    let runningApps = workspace.runningApplications.filter { $0.activationPolicy == .regular }
    if input.isEmpty || (input.first?.isEmpty ?? false) {
      return runningApps.map { DisplayableContainer(name: $0.localizedName!, content: $0.bundleURL!.path, icon: $0.icon!, innerItem: $0) }
    } else {
      let filteredApps = runningApps.filter { $0.localizedName!.lowercased().contains(input.joined(separator: " ")) }
      return filteredApps.map { DisplayableContainer(name: $0.localizedName!, content: $0.bundleURL!.path, icon: $0.icon!, innerItem: $0) }
    }
  }
}

struct VolumeService: SystemService {
  let name: String = "Eject Volumes"
  let content: String = "Eject selected volumes"
  static let keyword: String = "eject"
  var icon: NSImage {
    return #imageLiteral(resourceName: "eject").tintedImage(with: TonnerreTheme.current.imgColour)
  }
  let argUpperBound: Int = Int.max
  let argLowerBound: Int = 0
  
  private func send(notification: NSUserNotification) {
    let centre = NSUserNotificationCenter.default
    centre.deliver(notification)
  }
  
  func serve(source: Displayable, withCmd: Bool) {
    let workspace = NSWorkspace.shared
    let localNotification = NSUserNotification()
    let queue = DispatchQueue.global(qos: .userInitiated)
    if let allVolumes = (source as? DisplayableContainer<[URL]>)?.innerItem {
      queue.async {
        var errorCount = 0
        for volume in allVolumes {
          do {
            try workspace.unmountAndEjectDevice(at: volume)
          } catch {
            errorCount += 1
            localNotification.title = "Eject Failed"
            localNotification.informativeText = "Error: \(error)"
            localNotification.soundName = NSUserNotificationDefaultSoundName
            self.send(notification: localNotification)
          }
        }
        if errorCount == 0 {
          localNotification.title = "Eject Successfully"
          localNotification.informativeText = "Successfully ejected all volumes"
          localNotification.soundName = nil
          self.send(notification: localNotification)
        }
      }
    } else if let specificVolume = (source as? DisplayableContainer<URL>)?.innerItem {
      queue.async {
        do {
          try workspace.unmountAndEjectDevice(at: specificVolume)
          localNotification.title = "Eject Successfully"
          localNotification.informativeText = "Ejected: \(specificVolume.lastPathComponent)"
          localNotification.soundName = nil
        } catch {
          localNotification.title = "Eject Failed"
          localNotification.informativeText = "Error: \(error)"
          localNotification.soundName = NSUserNotificationDefaultSoundName
        }
        self.send(notification: localNotification)
      }
    }
  }
  
  func prepare(input: [String]) -> [Displayable] {
    let fileManager = FileManager.default
    let volumeURLs = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeIsInternalKey], options: .skipHiddenVolumes) ?? []
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
