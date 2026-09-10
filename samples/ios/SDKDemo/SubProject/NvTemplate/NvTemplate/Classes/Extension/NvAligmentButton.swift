//
//  NvAligmentButton.swift
//  NvTemplateModule
//
//  Created by Meishe on 2024/2/1.
//

import UIKit

open class NvAligmentButton: UIButton {
    public enum ImageStyle {
        case left, right, top, bottom
    }
    
    public var space: CGFloat = 8.0
    public var style: ImageStyle = .top
    
    open func nv_resetLayout(for style: ImageStyle, space: CGFloat) {
        self.style = style
        self.space = space
        setNeedsLayout() // Trigger a layout update
    }
    
    // Override layoutSubviews to layout imageView and titleLabel
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let imageView = imageView, let titleLabel = titleLabel else {
            return
        }
        titleLabel.sizeToFit() // Adjust the size of titleLabel to fit its content
        
        switch style {
        case .left:
            titleLabel.textAlignment = .left
            nv_layout(imageLeft: space)
        case .right:
            titleLabel.textAlignment = .right
            nv_layout(imageRight: space)
        case .top:
            titleLabel.textAlignment = .center
            nv_layout(imageTop: space)
        case .bottom:
            titleLabel.textAlignment = .center
            nv_layout(imageBottom: space)
        }
    }
    
    private func nv_layout(imageLeft space: CGFloat) {
        guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
        let imageSize = imageView.frame.size
        let titleSize = titleLabel.frame.size
        
        let totalWidth = imageSize.width + titleSize.width + space
        let imageOffsetX = (bounds.width - totalWidth) / 2
        let titleOffsetX = imageOffsetX + imageSize.width + space
        
        imageView.frame.origin = CGPoint(x: imageOffsetX, y: (bounds.height - imageSize.height) / 2)
        titleLabel.frame.origin = CGPoint(x: titleOffsetX, y: (bounds.height - titleSize.height) / 2)
    }

    private func nv_layout(imageRight space: CGFloat) {
        guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
        let imageSize = imageView.frame.size
        let titleSize = titleLabel.frame.size
        
        let totalWidth = imageSize.width + titleSize.width + space
        let titleOffsetX = (bounds.width - totalWidth) / 2
        let imageOffsetX = titleOffsetX + titleSize.width + space
        
        titleLabel.frame.origin = CGPoint(x: titleOffsetX, y: (bounds.height - titleSize.height) / 2)
        imageView.frame.origin = CGPoint(x: imageOffsetX, y: (bounds.height - imageSize.height) / 2)
    }

    private func nv_layout(imageTop space: CGFloat) {
        guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
        let imageSize = imageView.frame.size
        let titleSize = titleLabel.frame.size
        
        let totalHeight = imageSize.height + titleSize.height + space
        let imageOffsetY = (bounds.height - totalHeight) / 2
        let titleOffsetY = imageOffsetY + imageSize.height + space
        
        imageView.frame.origin = CGPoint(x: (bounds.width - imageSize.width) / 2, y: imageOffsetY)
        titleLabel.frame.origin = CGPoint(x: (bounds.width - titleSize.width) / 2, y: titleOffsetY)
    }

    private func nv_layout(imageBottom space: CGFloat) {
        guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
        let imageSize = imageView.frame.size
        let titleSize = titleLabel.frame.size
        
        let totalHeight = imageSize.height + titleSize.height + space
        let titleOffsetY = (bounds.height - totalHeight) / 2
        let imageOffsetY = titleOffsetY + titleSize.height + space
        
        titleLabel.frame.origin = CGPoint(x: (bounds.width - titleSize.width) / 2, y: titleOffsetY)
        imageView.frame.origin = CGPoint(x: (bounds.width - imageSize.width) / 2, y: imageOffsetY)
    }

    public init(frame: CGRect, style: ImageStyle = .top, space: CGFloat = 8.0) {
        self.style = style
        self.space = space
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
