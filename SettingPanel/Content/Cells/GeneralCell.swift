//
//  GeneralCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-02.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class GeneralCell: SettingCell {
  
  @IBOutlet weak var switchControl: Switch! {
    didSet {
      switchControl.delegate = self
    }
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    
    view.menu = createMenu(withName: item.name)
  }
  
  private func createMenu(withName name: String) -> NSMenu {
    let menu = NSMenu(title: "Setting")
    menu.autoenablesItems = false
    let defaultItem = NSMenuItem(title: "Set \"\(name)\" as Default Provider",
      action: #selector(setDefaultProvider(_:)), keyEquivalent: "")
    defaultItem.tag = 0
    
    let deleteItem = NSMenuItem(title: "Delete \"\(name)\"",
      action: #selector(deleteProvider(_:)), keyEquivalent: "")
    deleteItem.tag = 1
    
    menu.addItem(defaultItem)
    menu.addItem(deleteItem)
    return menu
  }

  @objc func deleteProvider(_ sender: Any) {
    do {
      try removeFile()
      delegate?.remove(cell: self)
    } catch {
      let alert = NSAlert()
      alert.informativeText = "Error happened"
      alert.messageText = "\(error)"
      alert.addButton(withTitle: "OK")
      alert.runModal()
    }
  }
  
  private func removeFile() throws {
    guard
      let id = item.settingKey
    else { return }
    let lastComponent = id.replacingOccurrences(of: "Tonnerre.Provider.Extension.", with: "")
    let servicesFolder = SupportFolders.services.path
    let serviceURL = servicesFolder.appendingPathComponent("\(lastComponent).tne")
    try FileManager.default.removeItem(at: serviceURL)
  }
  
  private func toggleAvailability(ofProvider id: String, enable: Bool) {
    if enable {
      DisableManager.shared.enable(providerID: id)
    } else {
      DisableManager.shared.disable(providerID: id)
    }
  }
  
  @objc private func setDefaultProvider(_ sender: Any) {
    guard
      let id = item.settingKey,
      !DisableManager.shared.isDisabled(providerID: id)
    else { return }
    DefaultProvider.id = id
  }
  
  override func menuWillOpen(view: NSView, menu: NSMenu, with event: NSEvent) {
    for menuItem in menu.items {
      if menuItem.tag == 0, let id = item.settingKey {
        menuItem.isEnabled = !DisableManager.shared.isDisabled(providerID: id)
      } else if menuItem.tag == 1 {
        menuItem.isEnabled = indexPath.section != 0
      }
    }
  }
}

extension GeneralCell: SwitchDelegate {
  func valueDidChange(sender: Any) {
    guard
      let key = item.settingKey,
      let switchControl = sender as? Switch
    else { return }
    toggleAvailability(ofProvider: key, enable: switchControl.state == .on)
  }
}
