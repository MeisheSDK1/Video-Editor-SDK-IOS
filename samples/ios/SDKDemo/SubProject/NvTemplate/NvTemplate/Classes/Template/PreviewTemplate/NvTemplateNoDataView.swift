//
//  NvTemplateNoDataView.swift
//  MYVideo
//
//  Created by chengww on 2021/1/20.
//  Copyright © 2021 MEISHE. All rights reserved.
//

import UIKit

class NvTemplateNoDataView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        let imageView = UIImageView.init(frame: CGRect.init(x: (frame.size.width - 112 * SCREENSCALE) * 0.5, y: 170 * SCREENSCALE, width: 112 * SCREENSCALE, height: 74 * SCREENSCALE))
        imageView.image = NvUtils.imageWithName( "template_no_data")
        self.addSubview(imageView)
        let textLabel = UILabel.init(frame: CGRect.init(x: 10, y: imageView.frame.maxY + 22 * SCREENSCALE, width: frame.size.width - 20, height: 14 * SCREENSCALE))
        textLabel.text = NvLocalProvider.String(key: "No template data display", comment: "暂无模板内容")
        textLabel.textColor = UIColor.white
        textLabel.textAlignment = .center
        textLabel.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
        self.addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
