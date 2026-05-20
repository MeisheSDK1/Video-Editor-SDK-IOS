//
//  NvProgressView.swift
//  MYVideo
//
//  Created by chengww on 2020/12/29.
//  Copyright © 2020 MEISHE. All rights reserved.
//

import UIKit

extension NvProgressView {
    public struct Options {
        var progressColor: UIColor = UIColor.init(r: 252.0, g: 43.0, b: 85.0)
        var progressTrackColor: UIColor = UIColor.init(r: 54.0, g: 54.0, b: 54.0)
        var backgroundColor: UIColor = UIColor.init(r: 16.0, g: 16.0, b: 16.0)
        var progressWidth: CGFloat = 5
        var textColor: UIColor = UIColor.white
        var textFont: UIFont = NvUtils.fontWithSize(size: 12.0 * SCREENSCALE)
        init() { }
    }
}

class NvProgressView: UIView {
    var percent: CGFloat = 0 {
        didSet {
            guard percent >= 0 else { return }
            self.progressLabel.text = NvUtils.CGFloatToString(percent * 100, afterPoint: 0) + "%"
            let trackPath = UIBezierPath.init(arcCenter: nvcenter, radius: nvradius, startAngle: CGFloat.pi * -0.5, endAngle: CGFloat.pi * 2 * self.percent + CGFloat.pi * -0.5, clockwise: true)
            trackLayer.path = trackPath.cgPath
        }
    }
    init(frame: CGRect, opt: NvProgressView.Options) {
        super.init(frame: frame)
        self.config = opt
        self.progressLabel.frame = self.bounds
        self.progressLabel.backgroundColor = UIColor.clear
        self.progressLabel.font = self.config.textFont
        self.progressLabel.textColor = self.config.textColor
        self.progressLabel.textAlignment = .center
    }
    init(for opt: NvProgressView.Options) {
        super.init(frame: .zero)
        self.config = opt
        self.progressLabel.backgroundColor = UIColor.clear
        self.progressLabel.font = self.config.textFont
        self.progressLabel.textColor = self.config.textColor
        self.progressLabel.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = self.config.backgroundColor
        self.progressLabel.frame = self.bounds
        self.addSubview(self.progressLabel)
        /// 创建背景图层
        /// Create background Layer
        let backgroundLayer = CAShapeLayer.init()
        backgroundLayer.fillColor = nil
        backgroundLayer.frame = self.bounds
        /// 创建填充图层
        /// Create a fill layer
        trackLayer.fillColor = nil
        trackLayer.frame = self.bounds
        trackLayer.strokeColor = self.config.progressColor.cgColor
        backgroundLayer.strokeColor = self.config.progressTrackColor.cgColor
        nvcenter = CGPoint.init(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        nvradius = (self.bounds.size.width - self.config.progressWidth) * 0.5
        let backPath = UIBezierPath.init(arcCenter: nvcenter, radius: nvradius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        backgroundLayer.path = backPath.cgPath
        trackLayer.lineWidth = self.config.progressWidth
        backgroundLayer.lineWidth = self.config.progressWidth
        self.layer.addSublayer(backgroundLayer)
        self.layer.addSublayer(trackLayer)
        
    }
    private var config: NvProgressView.Options!
    private var nvcenter: CGPoint = .zero
    private var nvradius: CGFloat = 0
    private let trackLayer: CAShapeLayer = CAShapeLayer.init()
    private let progressLabel: UILabel = UILabel.init()
}

