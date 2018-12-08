//
//  LiteTableVCDelegate.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-10-19.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol LiteTableVCDelegate: class {
  /**
   A service is selected and highlighted
   - parameter service: the service pack which is selected
   */
  func serviceHighlighted(service: ServicePack?)
  /**
   Request to fill in the placeholder field with given service
   - parameter service: the service highlighted and needs to be filled in the placeholder field
   */
  func updatePlaceholder(service: ServicePack?)
  /**
   Request to fill in the placeholder field with given service
   - parameter string: the content needs to be set as placeholder
   */
  func updatePlaceholder(string: String?)
  /**
   Tab key is pressed, and request for auto completion
   - parameter service: the highlighted service that needs to be completed
   */
  func tabPressed(service: ServicePack)
  /**
   Request to retrieve the last queried content
   */
  func retrieveLastQuery()
  /**
   Service is selected with enter key or double click
   - parameter servicePack: the service with its provider
   - parameter withCmd: a flag indicates whether the cmd key is pressed with selection
   */
  func serve(_ servicePack: ServicePack, withCmd: Bool)
}
