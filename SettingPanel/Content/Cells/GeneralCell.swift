//
//  GeneralCell.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-02.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class GeneralCell: SettingCell {
  
  @IBOutlet weak var switchControl: Switch!

  override func viewWillAppear() {
    super.viewWillAppear()
    
    view.menu = createMenu(withName: item.name)
  }
  
  private func createMenu(withName name: String) -> NSMenu {
    let menu = NSMenu(title: "Setting")
    menu.autoenablesItems = false
    
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
    menu.items.removeAll()
    let itemDisabled: Bool
    if let id = item.settingKey {
      itemDisabled = DisableManager.shared.isDisabled(providerID: id)
    } else { itemDisabled = true }
    menu.addItem(NSMenuItem.getDefaultItem(name: item.name,
                                           action: #selector(setDefaultProvider(_:)),
                                           enabled: !itemDisabled))
    menu.addItem(NSMenuItem.getDeleteItem(name: item.name,
                                           action: #selector(deleteProvider(_:)),
                                           enabled: indexPath.section != 0))
  }
  
  @IBAction func valueDidChange(_ sender: Switch) {
    guard
      let key = item.settingKey
    else { return }
    toggleAvailability(ofProvider: key, enable: sender.state == .on)
  }
}

fileprivate extension NSMenuItem {
  static func getDefaultItem(name: String, action: Selector, enabled: Bool) -> NSMenuItem {
    let item = NSMenuItem(title: "Set \"\(name)\" as Default Provider",
      action: action, keyEquivalent: "")
    item.isEnabled = enabled
    return item
  }
  
  static func getDeleteItem(name: String, action: Selector, enabled: Bool) -> NSMenuItem {
    let item = NSMenuItem(title: "Delete \"\(name)\"",
      action: action, keyEquivalent: "")
    item.isEnabled = enabled
    return item
  }
}
