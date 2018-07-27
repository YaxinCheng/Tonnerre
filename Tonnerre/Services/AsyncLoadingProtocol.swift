//
//  AsyncLoadingProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-07-26.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

enum LoadingMode {
  case append
  case replaced
}

protocol AsyncLoadingProtocol {
  var mode: LoadingMode { get }
  func present(suggestions: [Any]) -> [ServiceResult]
}
