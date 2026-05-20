//
//  NvPageViewManager.swift
//  MYVideo
//
//  Created by 刘东旭 on 2019/12/19.
//  Copyright © 2019 刘东旭. All rights reserved.
//

import UIKit

open class NvPageViewManager: NSObject {
        
    private (set) public var style: PageStyle
    private (set) public var titles: [String]
    private (set) public var subViews: [UIView]
    private (set) public var startIndex: Int
    private (set) public lazy var titleView = PageTitleView(frame: .zero, style: style, titles: titles, currentIndex: startIndex)
    private (set) public lazy var contentView = NvPageContentView(frame: .zero, style: style, subViews: subViews, currentIndex: startIndex)

    public init(style: PageStyle, titles: [String], subViews: [UIView], startIndex: Int = 0) {
        self.style = style
        self.titles = titles
        self.subViews = subViews
        self.startIndex = startIndex
        super.init()
        
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension NvPageViewManager {
    private func setupUI() {
        
        titleView.delegate = contentView
        contentView.delegate = titleView
    }
}
