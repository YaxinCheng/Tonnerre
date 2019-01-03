//
//  URL+Extension.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-05-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Foundation

extension URL {
  /**
   /Users/cheng/Documents is a child of /Users and /Users/cheng
  */
  func isChildOf(url: URL) -> Bool {
    guard self.path.count > url.path.count else { return false }
    let selfComponents = self.pathComponents
    let otherComponents = url.pathComponents
    return zip(selfComponents, otherComponents).map(==).reduce(true, { $0 && $1 })
  }
  
  func isHiddenDescendent() -> Bool {
    return isDescendant {
      do {
        let resource = try $0.resourceValues(forKeys: [.isHiddenKey])
        return resource.isHidden ?? false
      } catch { return false }
    }
  }
  
  func isPackageDescendent() -> Bool {
    return isDescendant {
      do {
        let resource = try $0.resourceValues(forKeys: [.isPackageKey])
        return resource.isPackage ?? false
      } catch { return false }
    }
  }
  
  fileprivate func isDescendant(of standard: (URL)->Bool) -> Bool {
    var baseURL = URL(fileURLWithPath: "/")
    for component in pathComponents.dropLast() {
      baseURL.appendPathComponent(component)
      if standard(baseURL) { return true }
    }
    return false
  }
}
