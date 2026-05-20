//
//  NvCollectionViewLayout.swift
//  MYVideo
//
//  Created by chengww on 2020/11/12.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit

protocol NvCollectionViewLayoutDelegate: class {
    func waterFlowLayout(layout: NvCollectionViewLayout, indexPath: IndexPath, itemWidth : CGFloat) -> CGFloat
}

class NvCollectionViewLayout: UICollectionViewLayout {
    weak open var delegate : NvCollectionViewLayoutDelegate?
    var columnCount: Int = 2
    var columnMargin: CGFloat = 0
    var rowMargin: CGFloat = 0
    var contentEdgeInsets: UIEdgeInsets = .zero
    
    override func prepare() {
        super.prepare()
        guard let cView = self.collectionView else { return }
        self.columnHeights.removeAll()
        self.contentHeight = 0
        for _ in 0..<self.columnCount {
            self.columnHeights.append(self.contentEdgeInsets.top)
        }
        self.attrs.removeAll()
        let count: Int = (cView.numberOfItems(inSection: 0))
        let width: CGFloat = cView.frame.size.width
        let colMargin = CGFloat(self.columnCount - 1) * self.columnMargin
        let cellWidth = (width - self.contentEdgeInsets.left - self.contentEdgeInsets.right - colMargin) / CGFloat(self.columnCount)
        
        for index in 0..<count {
            let indexPath = IndexPath.init(item: index, section: 0)
            let attr = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
            let cellHeight: CGFloat = self.delegate?.waterFlowLayout(layout: self, indexPath: indexPath, itemWidth: cellWidth) ?? 0
            var minColumnHeight = self.columnHeights[0]
            var minColumn: Int = 0
            for i in 1..<self.columnCount {
                let colHeight = self.columnHeights[i]
                if colHeight < minColumnHeight {
                    minColumnHeight = colHeight
                    minColumn = i
                }
            }
            let cellX: CGFloat = self.contentEdgeInsets.left + CGFloat(minColumn) * (self.columnMargin + cellWidth)
            var cellY = minColumnHeight
            if cellY != self.contentEdgeInsets.top {
                cellY = self.rowMargin + cellY
            }
            attr.frame = CGRect.init(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
            let maxY = cellY + cellHeight
            self.columnHeights[minColumn] = maxY
            let maxContentHeight = self.columnHeights[minColumn]
            if CGFloat(self.contentHeight!) < CGFloat(maxContentHeight) {
                self.contentHeight = maxContentHeight
            }
            self.attrs.append(attr)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attrs
    }
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize.init(width: 0, height: CGFloat(self.contentHeight!) + CGFloat(self.contentEdgeInsets.bottom))
        }
        set {
            self.collectionViewContentSize = newValue
        }
    }
    fileprivate lazy var attrs : [UICollectionViewLayoutAttributes] = []
    fileprivate lazy var columnHeights : [CGFloat] = []
    fileprivate var contentHeight : CGFloat?
}
