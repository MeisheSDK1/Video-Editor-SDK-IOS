//
//  NvImageView.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit
import YYWebImage

extension UIImageView {
    func nv_image(urlString: String) {
        if !urlString.contains("/") {
            self.image = NvUtils.imageWithName(urlString)
        } else if urlString.hasPrefix("http") {
            /// 加载网络图片
            /// Load network picture
            self.yy_setImage(with: URL(string: urlString), options: YYWebImageOptions(rawValue: 2))
        } else {
            /// 加载本地图片文件
            /// Load the local image file
            self.yy_setImage(with: URL(fileURLWithPath: urlString), options: YYWebImageOptions(rawValue: 2))
        }
    }
}

