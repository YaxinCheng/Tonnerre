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
    
//    deleteButton.isHidden = indexPath.section == 0
    view.menu = createMenu(withName: item.name)
  }
  
  private func createMenu(withName name: String) -> NSMenu {
    let menu = NSMenu(title: "Setting")
    menu.addItem(NSMenuItem(title: "Set \"\(name)\" as Default Provider",
      action: #selector(setDefaultProvider(_:)), keyEquivalent: ""))
    if indexPath.section > 0 {
      menu.addItem(NSMenuItem(title: "Delete \"\(name)\"",
        action: #selector(deleteProvider(_:)), keyEquivalent: ""))
    }
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
    let userDefault = UserDefaults.shared
    let serviceURL = userDefault.url(forKey: "appSupportDir")!
      .appendingPathComponent("Services/\(lastComponent).tne")
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
    guard let id = item.settingKey else { return }
    DefaultProvider.id = id
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
