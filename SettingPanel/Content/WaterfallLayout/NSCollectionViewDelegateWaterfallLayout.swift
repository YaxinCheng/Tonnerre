//
//  NSCollectionViewDelegateWaterfallLayout.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

protocol NSCollectionViewDelegateWaterfallLayout: class {
  func numberOfColumns(in collectionView: NSCollectionView) -> Int
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, heightForItemAt indexPath: IndexPath) -> CGFloat
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets
}

extension NSCollectionViewDelegateWaterfallLayout {
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 20
  }
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 20
  }
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
    return NSEdgeInsetsZero
  }
}
