//
//  WaterfallLayout.swift
//  SettingPanel
//
//  Created by Yaxin Cheng on 2018-12-22.
//  Copyright © 2018 Yaxin Cheng. All rights reserved.
//

import Cocoa

final class WaterfallLayout: NSCollectionViewLayout {
  weak var delegate: NSCollectionViewDelegateWaterfallLayout?
  
  private var contentHeight: CGFloat = 0
  private var columnWidth: CGFloat {
    guard let collectionView = collectionView else { return 0 }
    let numOfCols = delegate?.numberOfColumns(in: collectionView) ?? 1
    return collectionViewContentSize.width / CGFloat(numOfCols)
  }
  
  private var cache: [[NSCollectionViewLayoutAttributes]] = []
  
  override var collectionViewContentSize: NSSize {
    guard let collectionView = collectionView else { return .zero }
    if let connectedDelegate = delegate {
      let contentInsets = (0..<collectionView.numberOfSections).map {
        connectedDelegate.collectionView(collectionView, layout: self, insetForSectionAt: $0)
      }
      let minRight = contentInsets.map { $0.right }.min()!
      return NSSize(width: collectionView.bounds.width - minRight,
                    height: contentHeight)
    } else {
      return super.collectionViewContentSize
    }
  }
  
  override func prepare() {
    guard
      cache.isEmpty,
      let collectionView = collectionView
    else { return }
    
    let xOffsets = (0 ..< (delegate?.numberOfColumns(in: collectionView) ?? 0)).map {
      CGFloat($0) * columnWidth
    }
    var column = 0
    let TopInset = delegate?.collectionView(collectionView, layout: self, insetForSectionAt: 0) ?? NSEdgeInsetsZero
    var yOffsets = [CGFloat](repeating: TopInset.top, count: delegate?.numberOfColumns(in: collectionView) ?? 0)
    for section in 0 ..< collectionView.numberOfSections {
      let inset = delegate?.collectionView(collectionView, layout: self, insetForSectionAt: section) ?? NSEdgeInsetsZero
      var cacheAtSection: [NSCollectionViewLayoutAttributes] = []
      for item in 0 ..< collectionView.numberOfItems(inSection: section) {
        let indexPath = IndexPath(item: item, section: section)
        let itemHeight = delegate?.collectionView(collectionView, layout: self, heightForItemAt: indexPath) ?? 0
        let spacing = delegate?.collectionView(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? 0
        let height = itemHeight + spacing * 2
        let xPos = xOffsets[column] == 0 ? inset.left / 2 : xOffsets[column] + spacing
        let frame = NSRect(x: xPos, y: yOffsets[column], width: columnWidth, height: height)
        let insetsFrame = frame.insetBy(dx: spacing, dy: spacing)
        let attribute = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
        attribute.frame = insetsFrame
        cacheAtSection.append(attribute)
        
        contentHeight = max(contentHeight, frame.maxY)
        yOffsets[column] += height
        
        column = (column + 1) % (delegate?.numberOfColumns(in: collectionView) ?? 1)
      }
      cache.append(cacheAtSection)
      guard let maxYOffSet = yOffsets.max() else { return }
      let minSectionSpacing = delegate?.collectionView(collectionView, layout: self, minimumLineSpacingForSectionAt: section) ?? 0
      yOffsets = [CGFloat](repeating: maxYOffSet + minSectionSpacing, count: yOffsets.count)
    }
  }
  
  override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
    let visibleAttributes = cache.map {
      $0.filter { attribute in attribute.frame.intersects(rect) }
    }.reduce([], +)
    return visibleAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
    return cache[indexPath.section][indexPath.item]
  }
}
