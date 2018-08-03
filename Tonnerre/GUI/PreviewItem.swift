//
//  PreviewItem.swift
//  Tonnerre
//
//  Created by Yaxin Cheng on 2018-06-14.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Quartz

final class PreviewItem: NSObject, QLPreviewItem {
  let previewItemTitle: String!
  let previewItemURL: URL!
  
  init(title: String, url: URL) {
    previewItemURL = url
    previewItemTitle = title
    super.init()
  }
}
