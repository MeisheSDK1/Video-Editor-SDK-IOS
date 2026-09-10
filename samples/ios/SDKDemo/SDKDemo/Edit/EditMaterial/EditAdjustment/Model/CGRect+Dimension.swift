//
//  CGRect+Dimension.swift
//  MYVideo
//
//  Created by 美摄 on 2020/4/5.
//  Copyright © 2019 美摄. All rights reserved.
//

import UIKit

extension CGRect{
    func leftTop() -> CGPoint {
        return CGPoint(x: minX, y: minY)
    }
    
    func leftBottom() -> CGPoint {
        return CGPoint(x: minX, y: maxY)
    }
    
    func rightTop() -> CGPoint {
        return CGPoint(x: maxX, y: minY)
    }
    
    func rightBottom() -> CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}
