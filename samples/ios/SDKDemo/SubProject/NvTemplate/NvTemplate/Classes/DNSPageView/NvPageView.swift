//
//  NvPageView.swift
//  MYVideo
//
//  Created by 刘东旭 on 2019/12/19.
//  Copyright © 2019 刘东旭. All rights reserved.
//

import UIKit

open class NvPageView: UIView {
    
    private (set) public var style: PageStyle
    private (set) public var titles: [String]
    private (set) public var subViews: [UIView]
    private (set) public var startIndex: Int
    private (set) public lazy var titleView = PageTitleView(frame: .zero, style: style, titles: titles, currentIndex: startIndex)
    private (set) public lazy var contentView = NvPageContentView(frame: .zero, style: style, subViews: subViews, currentIndex: startIndex)


    public init(frame: CGRect, style: PageStyle, titles: [String], subViews: [UIView], startIndex: Int = 0) {
        self.style = style
        self.titles = titles
        self.subViews = subViews
        self.startIndex = startIndex
        super.init(frame: frame)
        
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension NvPageView {
    private func setupUI() {
        let titleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: style.titleViewHeight)
        titleView.frame = titleFrame
        addSubview(titleView)
        
        let contentFrame = CGRect(x: 0, y: style.titleViewHeight, width: bounds.width, height: bounds.height - style.titleViewHeight)
        contentView.frame = contentFrame
        addSubview(contentView)
        
        titleView.delegate = contentView
        contentView.delegate = titleView
    }
}
