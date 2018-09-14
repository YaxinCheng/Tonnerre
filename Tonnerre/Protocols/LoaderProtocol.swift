//
//  LoaderProtocol.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-09-13.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol LoaderProtocol {
  associatedtype DataType
  func find(keyword: String) -> [DataType]
}
