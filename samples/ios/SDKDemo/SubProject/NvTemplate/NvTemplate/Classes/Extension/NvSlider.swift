//
//  NvSlider.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit

class NvSlider: UISlider {
    public var valueLabel: UILabel?
    /// label和滑块的间距
    /// Spacing between label and slider
    public var margin: CGFloat = 0
    
    init(displayValue isDisplay: Bool = false) {
        super.init(frame: .zero)
        if isDisplay {
            valueLabel = UILabel.init()
            valueLabel?.textAlignment = .center
            valueLabel?.font = NvUtils.fontWithSize(size: 10 * SCREENSCALE)
            valueLabel?.textColor = UIColor.white
            addSubview(valueLabel!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: (self.frame.size.height - 2.5 * SCREENSCALE) * 0.5, width: self.frame.size.width, height: 2.5 * SCREENSCALE)
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect{
        var frame = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        frame.origin.x = bounds.size.width * CGFloat((value - minimumValue)/(maximumValue - minimumValue)) - frame.size.width * 0.5
        updatePosition(rect: frame)
        return frame
    }

    private func updatePosition(rect: CGRect) {
        if valueLabel != nil {
            valueLabel?.frame = CGRect.init(x: rect.origin.x + rect.size.width * 0.5 - 20, y: rect.origin.y - 20 - margin, width: 40, height: 20)
        }
    }
}
