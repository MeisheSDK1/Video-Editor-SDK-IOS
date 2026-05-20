//
//  NvDouCircleView.swift
//  SDKDemo
//
//  Created by 刘东旭 on 2019/11/29.
//  Copyright © 2019 meishe. All rights reserved.
//

import Foundation
import UIKit

class NvCircleView: UIView {
    private var circleLineWidth: CGFloat = 0.0
    private var circleFont: UIFont?
    private var circleColor: UIColor?

    private weak var cLabel: UILabel?
    private var _progress: CGFloat = 0
    public var progress: CGFloat {
        set{
            _progress = newValue
            cLabel?.text = String(format: "%d%%", Int(floor(newValue * 100)))

            setNeedsDisplay()
        }
        get{
            return _progress
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        circleLineWidth = 2.0
        circleFont = NvUtils.fontWithSize(size: 15.0)
        circleColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        ///百分比标签
        ///Percentage label
        let cLabel = UILabel(frame: self.bounds)
        cLabel.font = circleFont
        cLabel.textColor = circleColor
        cLabel.textAlignment = .center
        addSubview(cLabel)
        self.cLabel = cLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress: CGFloat) {
        self.progress = progress

        cLabel?.text = String(format: "%d%%", Int(floor(progress * 100)))

        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        ///路径
        ///path
        let path = UIBezierPath()
        ///线宽
        ///Line width
        path.lineWidth = CGFloat(circleLineWidth)
        ///颜色
        ///color
        circleColor?.set()
        ///拐角
        ///corner
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        ///半径
        ///radius
        let radius = (min(rect.size.width, rect.size.height) - circleLineWidth) * 0.5
        ///画弧（参数：中心、半径、起始角度(3点钟方向为0)、结束角度、是否顺时针）
        ///Draw arc (parameters: center, radius, start Angle (0 at 3 o 'clock), end Angle, whether clockwise)
        path.addArc(withCenter: CGPoint.init(x: rect.size.width * 0.5, y: rect.size.height * 0.5), radius: radius, startAngle: .pi * 1.5, endAngle: .pi * 1.5 + .pi * 2 * progress, clockwise: true)
        
        path.stroke()
    }
}
