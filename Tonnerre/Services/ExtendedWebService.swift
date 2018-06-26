//
//  ExtendedWebService.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

@objc protocol ExtendedWebService {
  init()
  var storedImage: NSImage? { get set }
  func loadImage()
}
