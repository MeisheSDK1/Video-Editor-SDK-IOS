//
//  NvSlider.swift
//  MYVideo
//
//  Created by 美摄 on 2020/3/12.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit

class NvSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: (self.frame.size.height - 2.5 * Cropper_SCREENSCALE) * 0.5, width: self.frame.size.width, height: 2.5 * Cropper_SCREENSCALE)
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect{
        var frame = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        frame.origin.x = bounds.size.width * CGFloat((value - minimumValue)/(maximumValue - minimumValue)) - frame.size.width * 0.5
        return frame
    }

}
