//
//  LoaderProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 This is the protocol used for all service loaders
 
 Service Loaders should returns an array of services with given keyword
 */
protocol ServiceLoader: class {
  /**
   The generic type for service
  */
  associatedtype ServiceType
  /**
   Cached key. Used to load services more quickly
   */
  var cachedKey: String { get set }
  /**
   Cached Service Providers. Used to load services more quickly
  */
  var cachedProviders: Array<ServiceType> { get set }
  /**
   This function should define the load process based on the keyword
   - warning: Do not call this function directly. Call `load(keyword:)` instead
   - parameter keyword: the keyword where services should be related to
   - returns: An array of services
   */
  func _find(keyword: String) -> [ServiceType]
}

extension ServiceLoader {
  /**
   This is the main function for each loader. It should load services based on given keyword.
   Every load is cached to reach a faster speed
   - parameter keyword: The keyword used to query services
   - returns: An array of services based on this keyword
  */
  func load(keyword: String) -> [ServiceType] {
    guard keyword != cachedKey else { return cachedProviders }
    cachedKey = keyword
    cachedProviders = _find(keyword: keyword)
    return cachedProviders
  }
}
