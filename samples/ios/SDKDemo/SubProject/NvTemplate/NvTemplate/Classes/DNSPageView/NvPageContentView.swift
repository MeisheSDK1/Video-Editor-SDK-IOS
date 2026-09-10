//
//  NvPageContentView.swift
//  MYVideo
//
//  Created by 刘东旭 on 2019/12/19.
//  Copyright © 2019 刘东旭. All rights reserved.
//

import UIKit

public protocol NvPageContentViewDelegate: class {
    func contentView(_ contentView: NvPageContentView, didEndScrollAt index: Int)
    func contentView(_ contentView: NvPageContentView, scrollingWith sourceIndex: Int, targetIndex: Int, progress: CGFloat)
}


private let CellID = "CellID"
open class NvPageContentView: UIView {
    
    public weak var delegate: NvPageContentViewDelegate?
    
    public weak var eventHandler: PageEventHandleable?
    
    public var style: PageStyle
    
    public var subViews : [UIView]
    
    /// 初始化后，默认显示的页数
    /// After initialization, the default number of pages to display
    public var currentIndex: Int
    
    private var startOffsetX: CGFloat = 0
    
    private var isForbidDelegate: Bool = false
    
    private (set) public lazy var collectionView: UICollectionView = {
        let layout = PageCollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
        collectionView.delaysContentTouches = false;
        collectionView.showsHorizontalScrollIndicator = false
        if #available(iOS 10, *) {
            collectionView.isPrefetchingEnabled = false
        }
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: CellID)
        return collectionView
    }()
    
    
    public init(frame: CGRect, style: PageStyle, subViews: [UIView], currentIndex: Int) {
        self.subViews = subViews
        self.style = style
        self.currentIndex = currentIndex
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.subViews = [UIView]()
        self.style = PageStyle()
        self.currentIndex = 0
        super.init(coder: aDecoder)
        
    }
    

    override open func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        let layout = collectionView.collectionViewLayout as! PageCollectionViewFlowLayout
        layout.itemSize = bounds.size
        layout.offset = CGFloat(currentIndex) * bounds.size.width
    }
}


extension NvPageContentView {
    public func setupUI() {
        addSubview(collectionView)
        
        collectionView.backgroundColor = style.contentViewBackgroundColor
        collectionView.isScrollEnabled = style.isContentScrollEnabled

    }
}


extension NvPageContentView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subViews.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID, for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        let subView = subViews[indexPath.item]

        eventHandler = subView as? PageEventHandleable
        subView.frame = cell.contentView.bounds
        cell.contentView.addSubview(subView)
        
        return cell
    }
}


extension NvPageContentView: UICollectionViewDelegate {
    
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidDelegate = false
        startOffsetX = scrollView.contentOffset.x
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUI(scrollView)
        
    }
    
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            collectionViewDidEndScroll(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        collectionViewDidEndScroll(scrollView)
    }
    
    
    private func collectionViewDidEndScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        
        delegate?.contentView(self, didEndScrollAt: index)
        
        if index != currentIndex {
            let subView = subViews[currentIndex]
            (subView as? PageEventHandleable)?.contentViewDidDisappear?()
        }
        
        currentIndex = index
        
        eventHandler = subViews[currentIndex] as? PageEventHandleable
        
        eventHandler?.contentViewDidEndScroll?()
        
    }

    
    
    private func updateUI(_ scrollView: UIScrollView) {
        if isForbidDelegate {
            return
        }
        
        var progress: CGFloat = 0
        var targetIndex = 0
        var sourceIndex = 0
        
        
        progress = scrollView.contentOffset.x.truncatingRemainder(dividingBy: scrollView.bounds.width) / scrollView.bounds.width
        if progress == 0 || progress.isNaN {
            return
        }
        
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        
        if collectionView.contentOffset.x > startOffsetX {
            ///左滑动
            ///Left slide
            sourceIndex = index
            targetIndex = index + 1
            guard targetIndex < subViews.count else { return }
        } else {
            sourceIndex = index + 1
            targetIndex = index
            progress = 1 - progress
            if targetIndex < 0 {
                return
            }
        }
        
        if progress > 0.998 {
            progress = 1
        }
        
        delegate?.contentView(self, scrollingWith: sourceIndex, targetIndex: targetIndex, progress: progress)
    }
}


extension NvPageContentView: PageTitleViewDelegate {
    public func titleView(_ titleView: PageTitleView, didSelectAt index: Int) {
        isForbidDelegate = true
        
        guard currentIndex < subViews.count else { return }
        
        currentIndex = index

        let indexPath = IndexPath(item: index, section: 0)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
}
