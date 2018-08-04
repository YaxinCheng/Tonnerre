//
//  AsyncLoadingProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-26.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

/**
 Asynchronized loading type for async services
*/
enum AsyncLoadingType {
  /**
   Append: append the asynchronously loaded actions to the existing services
  */
  case append
  /**
   Replaced: cover the existing services with the asynchronously loaded services
  */
  case replaced
}

/**
 Any service loading content asynchronously should conform to this protocol
*/
protocol AsyncLoadingProtocol {
  /**
   The loading type determines the display actions
  */
  var mode: AsyncLoadingType { get }
  /**
   Convert the raw suggestions loaded to types that can be displayed
   - parameter suggestions: any types of data that is loaded asynchronously from file, web, or anywhere
   - returns: a well structured array of ServiceResult that are ready to be displayed
  */
  func present(suggestions: [Any]) -> [ServiceResult]
}
