//
//  ContentViewController.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-10-25.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

class ContentViewController: NSViewController {
  
  @IBOutlet var scrollView: NSScrollView!
  weak var collectionView: NSCollectionView! {
    return scrollView.documentView as? NSCollectionView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    
  }
  
}
